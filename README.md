# PKG_READ_SQL
This Oracle PL/SQL utility package allows backend developers to convert data retrieved from SQL Statement to different file formats such as: .CSV, .DAT, .TXT, and other flat text files. This can be useful for automating data extraction process and of course, it streamlines the IT development process.

# SAMPLE PLSQL CODE TO GENERATE CSV
BEGIN
PKG_READ_SQL.GENERATE_CSV_FILE(
                 --Paste your SQL, take note of the ';' terminator ;
                    p_sql_query      => 'SELECT *
                                         FROM test_aging_report; ', 
                 --Preferred date format
                    p_date_format    => 'mm/dd/yyyy',
                 --Delimeter options: ',', '|', etc.
                    p_delimeter_type => ',',  
                 --Server Directory / to check path: select * from all_directories
                    p_dir            => 'TEMP_DIR', 
                 --File extension option
                    p_filename       => 'test1_'||TO_CHAR(SYSDATE, 'YYYYMonDD')||'.csv' 
                  );
END;
/

# SAMPLE PLSQL CODE TO GENERATE TXT
BEGIN
PKG_READ_SQL.GENERATE_FLAT_FILE(
                 --Paste your SQL, take note of the ';' terminator ;
                    p_sql_query      => 'SELECT *
                                         FROM test_aging_report; ', 
                 --Preferred date format
                    p_date_format    => 'mm/dd/yyyy',
                 --Delimeter options: ',', '*', etc., default is ' ' 
                    p_delimeter_type => NULL,  
                 --Column spacing
                    p_max_col_width  => 20,
                 --Server Directory / to check path: select * from all_directories
                    p_dir            => 'TEMP_DIR', 
                 --File extension options: .txt, .dat, etc.
                    p_filename       => 'test1_'||TO_CHAR(SYSDATE, 'YYYYMonDD')||'.txt' 
                  );
END;
/
