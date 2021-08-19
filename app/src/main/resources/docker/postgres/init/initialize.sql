CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE TABLE account
(
  id           UUID      DEFAULT gen_random_uuid(),
  username     VARCHAR(20) NOT NULL,
  name         VARCHAR(50),
  password     VARCHAR(60),
  email        VARCHAR(50),
  role         VARCHAR(20) NOT NULL,
  activation   BOOLEAN,
  code         VARCHAR(20),
  cell_phone   VARCHAR(18),
  reg_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  mod_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT account_pk PRIMARY KEY (id),
  CONSTRAINT account_uk_username UNIQUE (username)
);
CREATE TABLE cell_model
(
  id              UUID      DEFAULT gen_random_uuid(),
  name            VARCHAR(50) NOT NULL,
  manufacturer    VARCHAR(50),
  capacity        DOUBLE PRECISION,
  nominal_voltage DOUBLE PRECISION,
  reg_datetime    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  mod_datetime    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  registrant_id   UUID,
  CONSTRAINT cell_model_pk PRIMARY KEY (id),
  CONSTRAINT cell_model_uk_name UNIQUE (name),
  CONSTRAINT registrant_id_fk FOREIGN KEY (registrant_id) REFERENCES account (id)
);
CREATE TABLE battery_model
(
  id               UUID      DEFAULT gen_random_uuid(),
  name             VARCHAR(50)      NOT NULL,
  type             VARCHAR(20)      NOT NULL,
  nominal_voltage  DOUBLE PRECISION NOT NULL,
  nominal_capacity DOUBLE PRECISION NOT NULL,
  nominal_energy   DOUBLE PRECISION NOT NULL,
  serial_count     INT              NOT NULL,
  parallel_count   INT              NOT NULL,
  reg_datetime     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  mod_datetime     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  registrant_id    UUID,
  cell_model_id    UUID,
  CONSTRAINT battery_model_pk PRIMARY KEY (id),
  CONSTRAINT battery_model_uk_name UNIQUE (name),
  CONSTRAINT registrant_id_fk FOREIGN KEY (registrant_id) REFERENCES account (id),
  CONSTRAINT cell_model_id_fk FOREIGN KEY (cell_model_id) REFERENCES cell_model (id)
);

CREATE TABLE site
(
  id            UUID      DEFAULT gen_random_uuid(),
  name          VARCHAR(50) NOT NULL,
  zipcode       VARCHAR(5)  NOT NULL,
  country       VARCHAR(20) NOT NULL,
  state         VARCHAR(50) NOT NULL,
  city          VARCHAR(50) NOT NULL,
  address       VARCHAR(50) NOT NULL,
  latitude      DOUBLE PRECISION,
  longitude     DOUBLE PRECISION,
  code          VARCHAR(5)  NOT NULL,
  cellphone     VARCHAR(15) NOT NULL,
  manager_id    UUID        NOT NULL,
  registrant_id UUID        NOT NULL,
  reg_datetime  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  mod_datetime  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT site_pk PRIMARY KEY (id),
  CONSTRAINT manager_id_fk FOREIGN KEY (manager_id) REFERENCES account (id),
  CONSTRAINT registrant_id_fk FOREIGN KEY (registrant_id) REFERENCES account (id)
);

CREATE TABLE battery
(
  id               UUID      DEFAULT gen_random_uuid(),
  serial_no        VARCHAR(50) NOT NULL,
  equipment        VARCHAR(50) NOT NULL,
  defective        BOOLEAN     NOT NULL,
  prod_datetime    TIMESTAMP   NOT NULL,
  reg_datetime     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  site_id          UUID,
  registrant_id    UUID,
  producer_id      UUID,
  battery_model_id UUID,
  CONSTRAINT battery_pk PRIMARY KEY (id),
  CONSTRAINT battery_uk_serial_no UNIQUE (serial_no),
  CONSTRAINT site_id_fk FOREIGN KEY (site_id) REFERENCES site (id),
  CONSTRAINT registrant_id_fk FOREIGN KEY (registrant_id) REFERENCES account (id),
  CONSTRAINT producer_id_fk FOREIGN KEY (producer_id) REFERENCES account (id),
  CONSTRAINT battery_model_id_fk FOREIGN KEY (battery_model_id) REFERENCES battery_model (id)
);

CREATE TABLE bms
(
  id             UUID      DEFAULT gen_random_uuid(),
  serial_no      VARCHAR(50) NOT NULL,
  comm_serial_no VARCHAR(50) NOT NULL,
  firmware       VARCHAR(50) NOT NULL,
  model_name     VARCHAR(50) NOT NULL,
  reg_datetime   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  safety_mode    BOOLEAN     NOT NULL,
  battery_id     UUID,
  CONSTRAINT bms_pk PRIMARY KEY (id),
  CONSTRAINT bms_comm_serial_no_fk FOREIGN KEY (comm_serial_no) REFERENCES bms (serial_no),
  CONSTRAINT bms_uk_serial_no UNIQUE (serial_no)

);

BEGIN;
CREATE
  OR REPLACE FUNCTION update_timestamp()
  RETURNS TRIGGER AS
$$
BEGIN
  NEW.mod_datetime
    = now();
  RETURN new;
END;
$$
  LANGUAGE 'plpgsql';
COMMIT;

CREATE TRIGGER account_timestamp
  BEFORE INSERT OR
    UPDATE
  on account
  FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();
COMMIT;

CREATE TRIGGER cell_model_timestamp
  BEFORE INSERT OR
    UPDATE
  on cell_model
  FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();
COMMIT;

CREATE TRIGGER battery_model_timestamp
  BEFORE INSERT OR
    UPDATE
  on battery_model
  FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();
COMMIT;

CREATE TRIGGER site_timestamp
  BEFORE INSERT OR
    UPDATE
  on site
  FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();
COMMIT;

INSERT INTO account (username, name, password, email, role, activation, code, cell_phone)
VALUES ('admin', 'KPC Admin', '', 'admin@wisoft.space', 'ADMIN', TRUE, '', '');

CREATE TABLE sensing_data
(
  id             BIGINT GENERATED ALWAYS AS IDENTITY,
  comm_serial_no VARCHAR(50)              NOT NULL,
  datetime       TIMESTAMP WITH TIME ZONE NOT NULL,
  data           JSONB                    NOT NULL
);

INSERT INTO sensing_data (comm_serial_no, datetime, data)
VALUES ('01011112222', '2021-08-03:00:00:00', '{
  "soc": 21.8,
  "soh": 0,
  "current": 0,
  "ac_state": 0,
  "dc_state": 0,
  "low_temp": 0,
  "over_temp": 0,
  "cell_group1": {
    "temp": 27.5,
    "cell_vols": {
      "1": 3.27,
      "2": 3.27,
      "3": 3.27,
      "4": 3.27,
      "5": 3.27,
      "6": 3.27,
      "7": 3.27,
      "8": 3.27,
      "9": 3.27,
      "10": 3.27,
      "11": 3.27,
      "12": 3.27
    }
  },
  "cell_group2": {
    "temp": 27.2,
    "cell_vols": {
      "1": 3.27,
      "2": 3.27,
      "3": 3.27,
      "4": 3.27,
      "5": 3.27,
      "6": 3.27,
      "7": 3.27,
      "8": 3.27,
      "9": 3.27,
      "10": 3.27,
      "11": 3.27,
      "12": 3.27
    }
  },
  "cell_low_vol": 0,
  "process_code": 0,
  "cell_over_vol": 0,
  "cell_vols_max": 3.27,
  "cell_vols_min": 3.27,
  "total_low_vol": 0,
  "total_voltage": 78.69,
  "cell_deviation": 0,
  "temp_deviation": 0,
  "total_over_vol": 0,
  "charging_over_cur": 0,
  "discharging_over_cur": 0
}'),
       ('01011112222', '2021-08-03:00:00:01', '{
         "soc": 21.8,
         "soh": 0,
         "current": 0,
         "ac_state": 0,
         "dc_state": 0,
         "low_temp": 0,
         "over_temp": 0,
         "cell_group1": {
           "temp": 27.5,
           "cell_vols": {
             "1": 3.27,
             "2": 3.27,
             "3": 3.27,
             "4": 3.27,
             "5": 3.27,
             "6": 3.27,
             "7": 3.27,
             "8": 3.27,
             "9": 3.27,
             "10": 3.27,
             "11": 3.27,
             "12": 3.27
           }
         },
         "cell_group2": {
           "temp": 27.2,
           "cell_vols": {
             "1": 3.27,
             "2": 3.27,
             "3": 3.27,
             "4": 3.27,
             "5": 3.27,
             "6": 3.27,
             "7": 3.27,
             "8": 3.27,
             "9": 3.27,
             "10": 3.27,
             "11": 3.27,
             "12": 3.27
           }
         },
         "cell_low_vol": 0,
         "process_code": 0,
         "cell_over_vol": 0,
         "cell_vols_max": 3.27,
         "cell_vols_min": 3.27,
         "total_low_vol": 0,
         "total_voltage": 78.69,
         "cell_deviation": 0,
         "temp_deviation": 0,
         "total_over_vol": 0,
         "charging_over_cur": 0,
         "discharging_over_cur": 0
       }'),
       ('01011112222', '2021-08-03:00:00:02', '{
         "soc": 21.8,
         "soh": 0,
         "current": 0,
         "ac_state": 0,
         "dc_state": 0,
         "low_temp": 0,
         "over_temp": 0,
         "cell_group1": {
           "temp": 27.5,
           "cell_vols": {
             "1": 3.27,
             "2": 3.27,
             "3": 3.27,
             "4": 3.27,
             "5": 3.27,
             "6": 3.27,
             "7": 3.27,
             "8": 3.27,
             "9": 3.27,
             "10": 3.27,
             "11": 3.27,
             "12": 3.27
           }
         },
         "cell_group2": {
           "temp": 27.2,
           "cell_vols": {
             "1": 3.27,
             "2": 3.27,
             "3": 3.27,
             "4": 3.27,
             "5": 3.27,
             "6": 3.27,
             "7": 3.27,
             "8": 3.27,
             "9": 3.27,
             "10": 3.27,
             "11": 3.27,
             "12": 3.27
           }
         },
         "cell_low_vol": 0,
         "process_code": 0,
         "cell_over_vol": 0,
         "cell_vols_max": 3.27,
         "cell_vols_min": 3.27,
         "total_low_vol": 0,
         "total_voltage": 78.69,
         "cell_deviation": 0,
         "temp_deviation": 0,
         "total_over_vol": 0,
         "charging_over_cur": 0,
         "discharging_over_cur": 0
       }');
COMMIT;
