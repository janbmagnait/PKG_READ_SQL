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
                 --File extension options: .txt, .dat, .ls, etc.
                    p_filename       => 'test1_'||TO_CHAR(SYSDATE, 'YYYYMonDD')||'.txt' 
                  );
END;
/