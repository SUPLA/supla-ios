# supla-ios

> Part of **SUPLA** — an open smart home platform that brings together hardware manufacturers, the community, and users.  
> Learn more at https://www.supla.org

`supla-ios` is the **official iOS mobile application** for the SUPLA platform.
It is a client application that communicates with SUPLA Cloud using the public REST API and native SUPLA client components.

---

## What is this repository?

This repository contains the source code of the SUPLA iOS application distributed to end users.

The application is responsible for:

* user authentication,
* displaying channels and their states,
* sending control commands to the SUPLA server,
* receiving notifications,
* client-side UI and UX.

Automation logic and device communication are handled outside of the application.

---

## SUPLA architecture overview

SUPLA consists of multiple components that together form a complete smart home platform, including device firmware, server-side services, cloud applications, and client applications.

`supla-ios` is a **client application** in this architecture:

* it communicates with SUPLA server and SUPLA Cloud,
* it does not communicate directly with devices,
* it does not contain server-side automation or device connectivity logic.

For a high-level overview of the SUPLA architecture and how individual repositories fit together, see:

👉 [https://github.com/SUPLA](https://github.com/SUPLA)

---

## Contributing

Please read:

* [`CONTRIBUTING.md`](CONTRIBUTING.md)
* [`SECURITY.md`](SECURITY.md)

---

## Releases

Official application releases are distributed via the Apple App Store.

Source code releases and tags are available on GitHub:
[https://github.com/SUPLA/supla-ios/releases](https://github.com/SUPLA/supla-ios/releases)

---

## License

This project is licensed under the **GPL-2.0** license.

