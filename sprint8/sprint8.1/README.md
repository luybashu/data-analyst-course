## Setting Up the `.env` File

Before running the project, you will need to create a `.env` file to provide your MySQL credentials. Follow these steps:

1. Copy the `.env.template` file to `.env`.
    ```bash
   cp .env.template .env
    
3. Open the `.env` file and fill in the values:
    - `MYSQL_USER`: Your MySQL username.
    - `MYSQL_PASSWORD`: Your MySQL password.
    - `HOST`: The host where your MySQL server is running (usually `127.0.0.1` for localhost).
4. Save the `.env` file.
