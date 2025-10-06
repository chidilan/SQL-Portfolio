CREATE TABLE payment_methods (
payment_method_id tinyint(4) NOT NULL AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
PRIMARY KEY(payment_method_id)
);

CREATE TABLE clients (
client_id INT(11) NOT NULL PRIMARY KEY,
`name` VARCHAR(50) NOT NULL,
address VARCHAR(50) NOT NULL,
city VARCHAR(50) NOT NULL,
state CHAR(2) NOT NULL,
phone VARCHAR(50) DEFAULT NULL
);

CREATE TABLE invoices (
invoice_id int(11) NOT NULL,
`number` VARCHAR(50) NOT NULL,
client_id int(11) NOT NULL,
invoice_total DECIMAL(9,2) NOT NULL,
payment_total DECIMAL(9,2) NOT NULL DEFAULT '0.00',
invoice_date DATE NOT NULL,
due_date DATE NOT NULL,
payment_date DATE DEFAULT NULL,
PRIMARY KEY(invoice_id), KEY FK_client_id(client_id),
CONSTRAINT FK_client_id FOREIGN KEY (client_id)
REFERENCES clients(client_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE payments (
payment_id INT(11) NOT NULL AUTO_INCREMENT,
client_id INT(11) NOT NULL,
invoice_id INT(11) NOT NULL,
`date` DATE NOT NULL,
AMOUNT DECIMAL (9,2) NOT NULL,
payment_method TINYINT(4) NOT NULL,
PRIMARY KEY (payment_id),
KEY fk_client_id_idx(client_id),
KEY fk_invoice_id_idx (invoice_id),
KEY fk_payment_payment_method_idx(payment_method),
CONSTRAINT fk_payment_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON UPDATE CASCADE,
CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON UPDATE CASCADE,
CONSTRAINT fk_payment_method FOREIGN KEY (payment_method) REFERENCES payment_methods(payment_method_id)
);