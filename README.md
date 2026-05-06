# aircrack-ng on Ubuntu 24.04 arm64

If you're running Ubuntu 24.04 (Noble) on an arm64 device — a Rock 5B, a Pi, an Orange Pi, whatever, and you tried to install aircrack-ng the normal way, you already know:

```
E: Package 'aircrack-ng' has no installation candidate
```

The package exists for amd64 but not arm64 in the Noble repos. The fix is building from source, which is straightforward once you know what dependencies to grab. That's what this script does.

## What it installs

- `aircrack-ng` - the main cracker
- `airmon-ng` - puts your adapter in monitor mode
- `airodump-ng` - captures packets / scans networks
- `aireplay-ng` - injection and deauth
- `airdecap-ng` - decrypts captured traffic

Latest version, built directly from the [official aircrack-ng repo](https://github.com/aircrack-ng/aircrack-ng).

## Requirements

- Ubuntu 24.04 arm64 (tested on Armbian Noble on Rock 5B)
- A WiFi adapter that supports monitor mode and packet injection
- sudo access

## Usage

```bash
git clone https://github.com/slofi/aircrack-ng-arm64
cd aircrack-ng-arm64
chmod +x build.sh
./build.sh
```

That's it. The script handles dependencies, cloning, compiling with all cores, installing, and cleaning up after itself.

Compile time is a few minutes on something like a Rock 5B (RK3588). Slower boards will take longer, just let it run.

## After install

Check your adapter interface name first:

```bash
ip link show
# or
iw dev
```

Put it in monitor mode:

```bash
sudo airmon-ng start wlan0
```

Start capturing:

```bash
sudo airodump-ng wlan0mon
```

## Notes

- Builds are dynamically linked against system libraries. If you're on a significantly different Ubuntu/Armbian version than 24.04, you're better off running the script than copying a binary someone else compiled.
- The script cleans up the build directory after install so it doesn't leave gigabytes of compiled objects behind.
- Tested on: Armbian 26.x Noble, Rock 5B (RK3588, aarch64)

## Why does this exist

Because it kept coming up and the solution was always "build from source" with no script to actually do it. Now there is one.
