# UIM SAP Custom Domain Service

## Overview
The UIM SAP Custom Domain Service is a Dlang application built using Vibe.D and the UIM-Framework. It provides a robust service for managing custom domain configurations, ensuring application identity protection, and supporting multitenancy in SAP BTP extension landscapes.

## Features
- **Custom Domain Configuration**: Manage and configure custom domains seamlessly.
- **Application Identity Protection**: Upload and manage TLS/SSL certificates for secure communication.
- **Security Hardening**: Implement security measures to protect the application from vulnerabilities.
- **Management of Custom Domains**: Handle custom domains within SAP BTP extension landscapes.
- **Dashboard for KPIs**: Access key performance indicators and predictive expiration warnings through a dedicated dashboard.
- **Multitenancy Support**: Manage multiple tenants with tenant-specific configurations and operations.

## Project Structure
```
uim-sap-custom-domain-service
├── source
│   ├── app.d
│   ├── config
│   ├── controllers
│   ├── services
│   ├── models
│   ├── routes
│   ├── middleware
│   ├── repositories
│   └── utils
├── test
├── config
├── dub.sdl
├── .env.example
└── README.md
```

## Getting Started

### Prerequisites
- Dlang compiler
- DUB package manager
- Vibe.D framework

### Installation
1. Clone the repository:
   ```
   git clone https://github.com/UIMSolutions/uim-sap.git
   cd uim-sap/uim-sap-custom-domain-service
   ```

2. Install dependencies:
   ```
   dub install
   ```

### Running the Application
To run the application, execute:
```
dub run
```

### Configuration
Configuration files are located in the `config` directory. Modify `dev.json` or `prod.json` as needed for your environment.

### Testing
To run the tests, use:
```
dub test
```

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.