CREATE OR REPLACE
PACKAGE PKG_READ_SQL AS
/**********************************************
**
** Author: Jan Magnait
** Date: 10-02-2019
** Email: webspotph@gmail.com
**
** Changelog:
**   Date: 10-02-2019
**     Initial Release: SQL Conversion to CSV and Flat Text Files
******************************************************************************
******************************************************************************
Copyright (C) 2019 by Jan Magnait

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

******************************************************************************
******************************************** */

  PROCEDURE SQL_TO_CSV
  (  
    p_sql_query IN CLOB, 
    p_header_columns IN DBMS_SQL.varchar2a, 
    p_sql_query_columns  IN DBMS_SQL.varchar2a,
    p_date_format IN VARCHAR2,
    p_delimeter_type IN VARCHAR2,
    p_dir IN VARCHAR2,
    p_filename IN VARCHAR2  
  );

  PROCEDURE SQL_TO_TEXT
  (
    p_sql_query IN CLOB, 
    p_header_columns IN DBMS_SQL.varchar2a, 
    p_sql_query_columns  IN DBMS_SQL.varchar2a,
    p_date_format IN VARCHAR2,
    p_delimeter_type IN VARCHAR2,
    p_max_col_width IN NUMBER DEFAULT 20, 
    p_dir IN VARCHAR2,
    p_filename IN VARCHAR2
  );
  
  PROCEDURE GENERATE_CSV_FILE
  (
    p_sql_query IN CLOB, 
    p_date_format IN VARCHAR2,
    p_delimeter_type IN VARCHAR2,
    p_dir IN VARCHAR2,
    p_filename IN VARCHAR2
  );

  PROCEDURE GENERATE_FLAT_FILE
    (
      p_sql_query IN CLOB, 
      p_date_format IN VARCHAR2,
      p_delimeter_type IN VARCHAR2,
      p_max_col_width IN NUMBER DEFAULT 20,
      p_dir IN VARCHAR2,
      p_filename IN VARCHAR2
    ); 
  
  END;
/
create or replace
PACKAGE BODY PKG_READ_SQL 
AS
    /*variables to describe db tables*/
    t_c       INTEGER;
    t_col_cnt INTEGER;
    t_desc_tab dbms_sql.desc_tab2;
    v_row NUMBER := 0; 

    /*variables for arrays / sql statement*/
    v_header_columns DBMS_SQL.varchar2a;    
    v_query_columns DBMS_SQL.varchar2a;

  PROCEDURE SQL_TO_CSV
  (  
    p_sql_query IN CLOB, 
    p_header_columns IN DBMS_SQL.varchar2a, 
    p_sql_query_columns  IN DBMS_SQL.varchar2a,
    p_date_format IN VARCHAR2,
    p_delimeter_type IN VARCHAR2,
    p_dir IN VARCHAR2,
    p_filename IN VARCHAR2  
  ) 
  IS 
    v_ddl_string CLOB;
    v_index PLS_INTEGER; 
    v_query_index PLS_INTEGER;
      
    -- DBMS_SQL variables / Dynamic SQL syntax
    v_cursor_id NUMBER;
    v_rows_fetched NUMBER;
    
    BEGIN
      v_ddl_string := ' DECLARE CURSOR c1 IS  ';  
      v_ddl_string := v_ddl_string || P_SQL_QUERY || ' v_file UTL_FILE.file_type; '||
      ' v_write VARCHAR2(32000); ' || ' BEGIN ';  
      v_ddl_string := v_ddl_string ||  ' v_file := UTL_FILE.fopen('''|| P_DIR ||''', '''|| P_FILENAME ||''', ''w''); '; 
      v_ddl_string := v_ddl_string ||  ' pkg_sql_convert.set_format_mask('''||P_DATE_FORMAT||'''); ';
      v_ddl_string := v_ddl_string ||  ' pkg_sql_convert.set_delimeter('''||P_DELIMETER_TYPE||'''); ';
      
      
      v_index := P_HEADER_COLUMNS.FIRST; 
      LOOP
        EXIT WHEN v_index  IS NULL;
        v_ddl_string := v_ddl_string || ' v_write:= v_write || pkg_sql_convert.write_csv( '; 
        v_ddl_string := v_ddl_string || ''''; 
        v_ddl_string := v_ddl_string || P_HEADER_COLUMNS(v_index);
        v_ddl_string := v_ddl_string || '''';
        v_ddl_string := v_ddl_string ||' ); ';
        
        v_index := P_HEADER_COLUMNS.NEXT(v_index);
        
      END LOOP; 
      
      v_ddl_string := v_ddl_string || ' UTL_FILE.put_line( v_file, v_write ); ';
      v_ddl_string := v_ddl_string || ' v_write := NULL; ';
      v_ddl_string := v_ddl_string || ' FOR i IN c1 '; 
      v_ddl_string := v_ddl_string || ' LOOP ';
     
     v_query_index := P_SQL_QUERY_COLUMNS.FIRST;
      LOOP
        EXIT WHEN v_query_index  IS NULL;
        v_ddl_string := v_ddl_string || ' v_write:= v_write || pkg_sql_convert.write_csv( i.'; 
        v_ddl_string := v_ddl_string || P_SQL_QUERY_COLUMNS(v_query_index);
        v_ddl_string := v_ddl_string ||' ); ';
    --    logit( v_query_index, 'D');
        v_query_index := P_SQL_QUERY_COLUMNS.NEXT(v_query_index); 
      END LOOP;   
      
      v_ddl_string := v_ddl_string || ' UTL_FILE.put_line( v_file, v_write ); ';
      v_ddl_string := v_ddl_string || ' v_write := NULL; ';
      v_ddl_string := v_ddl_string || ' END LOOP; ';
      v_ddl_string := v_ddl_string || ' UTL_FILE.fclose( v_file ); ';
      v_ddl_string := v_ddl_string || ' END; ';
      
      
      v_cursor_id := DBMS_SQL.open_cursor;
      DBMS_SQL.PARSE(v_cursor_id, v_ddl_string, DBMS_SQL.NATIVE);
      v_rows_fetched := DBMS_SQL.EXECUTE(v_cursor_id);
      DBMS_SQL.CLOSE_CURSOR(v_cursor_id);    
    END SQL_TO_CSV;

  
  PROCEDURE SQL_TO_TEXT
  (
    p_sql_query IN CLOB, 
    p_header_columns IN DBMS_SQL.varchar2a, 
    p_sql_query_columns  IN DBMS_SQL.varchar2a,
    p_date_format IN VARCHAR2,
    p_delimeter_type IN VARCHAR2,
    p_max_col_width IN NUMBER DEFAULT 20, 
    p_dir IN VARCHAR2,
    p_filename IN VARCHAR2
  ) 
  IS 
    v_ddl_string CLOB;
    v_index PLS_INTEGER;
    v_query_index PLS_INTEGER;
      
    -- DBMS_SQL variables / Dynamic SQL syntax
    v_cursor_id NUMBER;
    v_rows_fetched NUMBER;
    
    --DEFAULT WIDTH SIZE   
    p_offset NUMBER := 5; 
    
  BEGIN
    v_ddl_string := ' DECLARE CURSOR c1 IS  ';  
    v_ddl_string := v_ddl_string || P_SQL_QUERY || 
                    ' v_file UTL_FILE.file_type; '||
                    ' v_write VARCHAR2(32000); ' || 
                    ' BEGIN ';  
    v_ddl_string := v_ddl_string ||  
                    ' v_file := UTL_FILE.fopen('''|| P_DIR ||''', '''|| P_FILENAME ||''', ''w''); ';
    v_ddl_string := v_ddl_string ||  
                    ' pkg_sql_convert.set_format_mask('''||P_DATE_FORMAT||'''); ';
    v_ddl_string := v_ddl_string ||  
                    ' pkg_sql_convert.set_delimeter('''||P_DELIMETER_TYPE||'''); ';
    
      v_index := P_HEADER_COLUMNS.FIRST; 
      LOOP
      EXIT WHEN v_index  IS NULL;    
          v_ddl_string := v_ddl_string || ' v_write:= v_write || pkg_sql_convert.write_line( '; 
          v_ddl_string := v_ddl_string || ''''; 
          v_ddl_string := v_ddl_string || P_HEADER_COLUMNS(v_index);
          v_ddl_string := v_ddl_string || ''''; 
          v_ddl_string := v_ddl_string ||', '||''||P_MAX_COL_WIDTH||''||'); ';
          v_ddl_string := v_ddl_string || '  v_write:= v_write || pkg_sql_convert.write_string( rpad('' '', '||''||P_OFFSET||''||')); ';   
          
      v_index := P_HEADER_COLUMNS.NEXT(v_index);   
      END LOOP; 
    
    v_ddl_string := v_ddl_string || ' UTL_FILE.put_line( v_file, v_write ); ';
    v_ddl_string := v_ddl_string || ' v_write := NULL; ';
    v_ddl_string := v_ddl_string || ' FOR i IN c1 '; 
    v_ddl_string := v_ddl_string || ' LOOP ';
    
      v_query_index := P_SQL_QUERY_COLUMNS.FIRST;
      LOOP
      EXIT WHEN v_query_index  IS NULL;
        v_ddl_string := v_ddl_string || ' v_write:= v_write || pkg_sql_convert.write_line(i.';
        v_ddl_string := v_ddl_string || P_SQL_QUERY_COLUMNS(v_query_index);
        v_ddl_string := v_ddl_string ||', '||''||P_MAX_COL_WIDTH||''||'); ';
        v_ddl_string := v_ddl_string || '  v_write:= v_write || pkg_sql_convert.write_string( rpad('' '', '||''||P_OFFSET||''||')); ';  
        
      v_query_index := P_SQL_QUERY_COLUMNS.NEXT(v_query_index); 
      END LOOP;   
      
    v_ddl_string := v_ddl_string || ' UTL_FILE.put_line( v_file, v_write ); ';
    v_ddl_string := v_ddl_string || ' v_write := NULL; ';
    v_ddl_string := v_ddl_string || ' END LOOP; ';
    v_ddl_string := v_ddl_string || ' UTL_FILE.fclose( v_file ); ';
    v_ddl_string := v_ddl_string || ' END; ';
    
    
    v_cursor_id := DBMS_SQL.open_cursor;
    DBMS_SQL.PARSE(v_cursor_id, v_ddl_string, DBMS_SQL.NATIVE);
    v_rows_fetched := DBMS_SQL.EXECUTE(v_cursor_id);
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);  
  END SQL_TO_TEXT;  
  
  PROCEDURE GENERATE_CSV_FILE
  (
    p_sql_query IN CLOB, 
    p_date_format IN VARCHAR2,
    p_delimeter_type IN VARCHAR2,
    p_dir IN VARCHAR2,
    p_filename IN VARCHAR2
  ) 
  IS
  BEGIN       
    t_c := dbms_sql.open_cursor;
    dbms_sql.parse( t_c, replace(p_sql_query, ';', ''), dbms_sql.native);
    dbms_sql.describe_columns2( t_c, t_col_cnt, t_desc_tab );
    
    FOR c IN 1 .. t_col_cnt
    LOOP
      v_row := v_row + 1;
      dbms_output.put_line( t_desc_tab( c ).col_name ||' '||v_row);
      v_header_columns(v_row) := t_desc_tab( c ).col_name;--passing of header values in the array
      v_query_columns(v_row) := t_desc_tab( c ).col_name;--passing of query's column in the array
    END LOOP;
                                                                                                                                             
    SQL_TO_CSV(p_sql_query, v_header_columns, v_query_columns, p_date_format, p_delimeter_type, p_dir, p_filename);
    dbms_sql.close_cursor( t_c );
    
      IF dbms_sql.is_open( t_c ) THEN
         dbms_sql.close_cursor( t_c );
      END IF;    
  END GENERATE_CSV_FILE; 
  
  PROCEDURE GENERATE_FLAT_FILE
    (
      p_sql_query IN CLOB, 
      p_date_format IN VARCHAR2,
      p_delimeter_type IN VARCHAR2,
      p_max_col_width IN NUMBER DEFAULT 20,
      p_dir IN VARCHAR2,
      p_filename IN VARCHAR2
    )
    IS
    BEGIN       
    t_c := dbms_sql.open_cursor;
    dbms_sql.parse( t_c, replace(p_sql_query, ';', ''), dbms_sql.native);
    dbms_sql.describe_columns2( t_c, t_col_cnt, t_desc_tab );
    
    FOR c IN 1 .. t_col_cnt
    LOOP
      v_row := v_row + 1;
      dbms_output.put_line( t_desc_tab( c ).col_name ||' '||v_row);
      v_header_columns(v_row) := t_desc_tab( c ).col_name;--passing of header values in the array
      v_query_columns(v_row) := t_desc_tab( c ).col_name;--passing of query's column in the array
    END LOOP;
                                                                                                                                             
    SQL_TO_TEXT(p_sql_query, v_header_columns, v_query_columns, p_date_format, p_delimeter_type, p_max_col_width, p_dir, p_filename);
    dbms_sql.close_cursor( t_c );
    
      IF dbms_sql.is_open( t_c ) THEN
         dbms_sql.close_cursor( t_c );
      END IF;
    END GENERATE_FLAT_FILE;   
  
END;  
/