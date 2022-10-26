# PKG_READ_SQL
This Oracle PL/SQL utility package allows backend developers to convert data retrieved from SQL Statement to different file formats such as: .CSV, .DAT, .TXT, and other text file formats. This is useful for automating data extraction and tremendously saves time on development process.

# SAMPLE PLSQL CODE TO GENERATE CSV
    BEGIN
    
    PKG_READ_SQL.GENERATE_CSV_FILE(
      p_sql_query      =>
                        'SELECT *
                         FROM test_aging_report; ', 
      p_date_format    => 
                        'mm/dd/yyyy',
      p_delimeter_type => ',',  
      p_dir            => 'TEMP_DIR', 
      p_filename       => 'test1_'||TO_CHAR(SYSDATE, 'YYYYMonDD')||'.csv' 
      );

    END;
    /

# SAMPLE PLSQL CODE TO GENERATE TXT
    BEGIN
  
    PKG_READ_SQL.GENERATE_FLAT_FILE(
      p_sql_query      => 'SELECT *
                           FROM test_aging_report; ', 
      p_date_format    => 'mm/dd/yyyy',
      p_delimeter_type => NULL,  
      p_max_col_width  => 20,
      p_dir            => 'TEMP_DIR', 
      p_filename       => 'test1_'||TO_CHAR(SYSDATE, 'YYYYMonDD')||'.txt' 
      );
      
    END;
    /
