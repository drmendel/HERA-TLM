#include <cspice_websocket.h>
#include <data_manager.h>
#include <SpiceUsr.h>
#include <curl/curl.h>
#include <boost/beast.hpp>
#include <boost/asio.hpp>
#include <thread>
#include <atomic>
#include <memory>
#include <iostream>
#include <chrono>

namespace asio = boost::asio;
namespace beast = boost::beast;
using tcp = asio::ip::tcp;

std::atomic<bool> keepRunning(true);

class WebSocketServer {
public:
    WebSocketServer(asio::io_context& ioc, short port, const std::string& message)
        : acceptor_(ioc, tcp::endpoint(tcp::v4(), port)), socket_(ioc), messageToSend_(message) {
        acceptConnection();
    }

private:
    void acceptConnection() {
        if (!keepRunning.load()) return;

        acceptor_.async_accept(socket_, [this](boost::system::error_code ec) {
            if (!ec) {
                std::make_shared<Session>(std::move(socket_), messageToSend_)->start();
            }
            acceptConnection();
        });
    }

    class Session : public std::enable_shared_from_this<Session> {
    public:
        Session(tcp::socket socket, const std::string& message)
            : ws_(std::move(socket)), message_(message) {}

        void start() {
            ws_.async_accept([self = shared_from_this()](boost::system::error_code ec) {
                if (!ec) self->sendMessage();
            });
        }

    private:
        void sendMessage() {
            std::cout << "Sending message: " << message_ << std::endl; // Print when data is sent
            ws_.async_write(asio::buffer(message_), [self = shared_from_this()](boost::system::error_code ec, std::size_t) {
                if (!ec) {
                    std::this_thread::sleep_for(std::chrono::milliseconds(100)); // Delay before closing
                    self->closeWebSocket();
                }
            });
        }

        void closeWebSocket() {
            ws_.async_close(beast::websocket::close_code::normal, [self = shared_from_this()](boost::system::error_code ec) {
                if (ec) {
                    std::cerr << "Server WebSocket Close Error: " << ec.message() << std::endl;
                }
            });
        }

        beast::websocket::stream<tcp::socket> ws_;
        std::string message_;
    };

    tcp::acceptor acceptor_;
    tcp::socket socket_;
    std::string messageToSend_;
};

void connectToServer(const std::string& host, short port) {
    try {
        asio::io_context ioc;
        tcp::resolver resolver(ioc);
        auto results = resolver.resolve(host, std::to_string(port));

        beast::websocket::stream<tcp::socket> ws(ioc);
        asio::connect(ws.next_layer(), results.begin(), results.end());
        ws.handshake(host, "/");

        beast::flat_buffer buffer;
        ws.read(buffer);

        std::cout << "Received: " << beast::buffers_to_string(buffer.data()) << std::endl;

        // Safe WebSocket shutdown
        boost::system::error_code ec;
        ws.close(beast::websocket::close_code::normal, ec);
        if (ec && ec != beast::websocket::error::closed) { // Ignore normal closure
            std::cerr << "WebSocket Close Error: " << ec.message() << std::endl;
        }
    } catch (const std::exception& e) {
        std::cerr << "Client Error: " << e.what() << std::endl;
    }
}

void waitForKeyPress() {
    std::cout << "Press Enter to exit...\n";
    std::cin.get();
    keepRunning = false;
}

int main() {
    std::cout << "Hello World\n\n";
    websocketHeaderTest();
    dataManagerHeaderTest();
    SpiceInt number = 1;
    if(number) std::cout << "SpiceUsr header is available!\n\n";
    std::string message = "Send from port A to port B";
    short port = 8080;
    asio::io_context ioc;
    WebSocketServer server(ioc, port, message);
    std::thread serverThread([&ioc]() {
        ioc.run();
    });
    std::this_thread::sleep_for(std::chrono::seconds(1));  // Give server time to start
    connectToServer("localhost", port);
    std::cout << "Boost:Beast header is available!\n\n";
    waitForKeyPress();
    ioc.stop();
    serverThread.join(); 
    std::cout << "Program exited successfully.\n";
    return 0;
}
