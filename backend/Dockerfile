FROM gcc:latest
WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y cmake
RUN mkdir build && cd build && cmake .. && make
CMD ["./build/spice-api"]
