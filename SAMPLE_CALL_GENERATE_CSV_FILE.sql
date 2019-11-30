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