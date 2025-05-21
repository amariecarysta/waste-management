const mysql = require('mysql2');

const pool = mysql.createPool({
  host:            'classmysql.engr.oregonstate.edu',
  user:            'cs340_drollina',
  password:        '6170',              
  database:        'cs340_drollina',
  waitForConnections: true,
  connectionLimit:    10,
  queueLimit:         0
}).promise();

module.exports = pool;