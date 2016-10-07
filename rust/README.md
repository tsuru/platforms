# Rust Platform

The Rust platform supports code deployment, the application is built in the
target.


## Code deployment

If you just run a ``git push`` of your code, tsuru will install the application
using ``cargo install`` – which fetches all the dependencies automatically.

##Binary deployment

For binary deployment, ensure the name of the binary file matches what's in
Procfile. Also make sure it matches the target platform (usually linux_amd64),
For example:

    $ ls
    Cargo.lock  Cargo.toml  src     target
    $ rustup target add x86_64-unknown-linux-gnu
    $ cargo build --release --target=x86_64-unknown-linux-gnu
    $ cat Procfile
    web: ./hello_world
    $ tsuru app-deploy -a [app-name] target/x86_64-unknown-linux-gnu/release/hello_world Procfile
