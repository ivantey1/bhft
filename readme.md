## Установка и запуск

1. Убедитесь, что у вас установлен Docker и Docker Compose.

2. Запустите PostgreSQL через Docker Compose:
   ```bash
   docker compose up -d
   ```

3. Скопируйте файлы данных в контейнер:
   ```bash
   docker compose cp data/dump_log.csv db:/tmp/dump_log.csv
   docker compose cp data/order_log.csv db:/tmp/order_log.csv
   docker compose cp data/own_trade_log.csv db:/tmp/own_trade_log.csv
   ```

4. Подключитесь к базе данных PostgreSQL:
   ```bash
   docker compose exec db psql -U postgres -d trading_data
   ```

5. Создайте таблицы и загрузите данные:
   - Выполните следующие команды для создания таблиц:
     ```sql
     CREATE TABLE dump_log (
         trace_id BIGINT,
         platform_time TIMESTAMP,
         direction VARCHAR(10),
         message_name VARCHAR(50),
         message_kind VARCHAR(20),
         message JSONB,
         correlation_id INTEGER
     );

     CREATE TABLE order_log (
         platform_time TIMESTAMP,
         exchange_time TIMESTAMP,
         trace_id BIGINT,
         account_name VARCHAR(50),
         instrument_name VARCHAR(50),
         order_id VARCHAR(50),
         exchange_order_id VARCHAR(50),
         status VARCHAR(20),
         status_reason VARCHAR(50),
         side VARCHAR(10),
         time_in_force VARCHAR(10),
         is_post_only BOOLEAN,
         price DECIMAL(36,18),
         original_amount DECIMAL(36,18),
         remaining_amount DECIMAL(36,18)
     );

     CREATE TABLE own_trade_log (
         platform_time TIMESTAMP,
         exchange_time TIMESTAMP,
         trace_id BIGINT,
         account_name VARCHAR(50),
         instrument_name VARCHAR(50),
         trade_id VARCHAR(50),
         exchange_trade_id VARCHAR(50),
         order_id VARCHAR(50),
         exchange_order_id VARCHAR(50),
         side VARCHAR(10),
         role VARCHAR(10),
         price DECIMAL(36,18),
         base_amount DECIMAL(36,18),
         base_asset_name VARCHAR(20),
         quote_amount DECIMAL(36,18),
         quote_asset_name VARCHAR(20),
         fee_amount DECIMAL(36,18),
         fee_asset_name VARCHAR(20),
         is_fee_evaluated BOOLEAN,
         source VARCHAR(20)
     );
     ```
   - Загрузите данные из файлов с помощью следующих команд:
     ```sql
     COPY dump_log FROM '/tmp/dump_log.csv' DELIMITER ',' CSV HEADER;
     COPY order_log FROM '/tmp/order_log.csv' DELIMITER ',' CSV HEADER;
     COPY own_trade_log FROM '/tmp/own_trade_log.csv' DELIMITER ',' CSV HEADER;
     ```

