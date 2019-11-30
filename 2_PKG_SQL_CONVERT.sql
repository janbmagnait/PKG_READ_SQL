CREATE OR REPLACE
PACKAGE pkg_sql_convert AS
  PROCEDURE set_format_mask( p_format_mask IN VARCHAR2 );
  PROCEDURE set_delimeter( p_delimeter IN VARCHAR2 );
  
  FUNCTION write_string(p_field IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION write_string(p_field IN NUMBER) RETURN VARCHAR2;
  FUNCTION write_string(p_field IN DATE) RETURN VARCHAR2;
  
  FUNCTION write_header_line(p_field IN VARCHAR2, p_max_col_width IN NUMBER DEFAULT 0, p_with_header_line IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2;
  
  FUNCTION write_line(p_field IN VARCHAR2, p_max_col_width IN NUMBER DEFAULT 0) RETURN VARCHAR2;
  FUNCTION write_line(p_field IN NUMBER, p_max_col_width IN NUMBER DEFAULT 0) RETURN VARCHAR2;
  FUNCTION write_line(p_field IN DATE, p_max_col_width IN NUMBER DEFAULT 0) RETURN VARCHAR2;

  FUNCTION write_csv(p_field IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION write_csv(p_field IN NUMBER) RETURN VARCHAR2;
  FUNCTION write_csv(p_field IN DATE) RETURN VARCHAR2;  

END;
/
create or replace
PACKAGE BODY        pkg_sql_convert AS
  g_format_mask VARCHAR2(50) := 'DD/MM/YYYY';
  g_delimeter   VARCHAR2(5) := ' ';
  PROCEDURE set_delimeter( p_delimeter IN VARCHAR2 )
  IS
  BEGIN
    g_delimeter := p_delimeter;
  END;  
  
  PROCEDURE set_format_mask( p_format_mask IN VARCHAR2 )
  IS
  BEGIN
    g_format_mask := p_format_mask;
  END;
  
  FUNCTION write_string(p_field IN VARCHAR2) RETURN VARCHAR2
  IS
  BEGIN
    RETURN p_field;
  END;

  FUNCTION write_string(p_field IN NUMBER) RETURN VARCHAR2
  IS
  BEGIN
    RETURN to_char(p_field);
  END;

  FUNCTION write_string(p_field IN DATE) RETURN VARCHAR2
  IS
  BEGIN
    RETURN to_char(p_field, g_format_mask);
  END;

  FUNCTION write_header_line(p_field IN VARCHAR2, p_max_col_width IN NUMBER DEFAULT 0, p_with_header_line IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2
  IS
  v_length NUMBER;
  BEGIN
  v_length := length(NVL(write_string(p_field), ' '));
     IF p_with_header_line = 'N' THEN
       RETURN RPAD(LPAD(NVL(write_string(p_field), ' '), v_length + ((p_max_col_width - v_length)/2),' '), v_length + (((p_max_col_width - v_length)/2)*2),' ');
     ELSIF p_with_header_line = 'Y' THEN
       RETURN RPAD(LPAD(NVL(write_string(p_field), '*'), v_length + ((p_max_col_width - v_length)/2),'*'), v_length + (((p_max_col_width - v_length)/2)*2),'*');
     END IF;
  END;

  FUNCTION write_line(p_field IN VARCHAR2, p_max_col_width IN NUMBER DEFAULT 0) RETURN VARCHAR2
  IS
  BEGIN
   RETURN  rpad(NVL(write_string(p_field)||g_delimeter, ' '), p_max_col_width, ' ');
  END;

  FUNCTION write_line(p_field IN NUMBER, p_max_col_width IN NUMBER DEFAULT 0) RETURN VARCHAR2
  IS
  BEGIN
    RETURN rpad(NVL(write_string(p_field)||g_delimeter, ' '), p_max_col_width, ' ');
  END;

  FUNCTION write_line(p_field IN DATE, p_max_col_width IN NUMBER DEFAULT 0) RETURN VARCHAR2
  IS
  BEGIN
    RETURN rpad(NVL(write_string(p_field)||g_delimeter, ' '), p_max_col_width, ' ') ;
  END;
 
  FUNCTION write_csv(p_field IN VARCHAR2) RETURN VARCHAR2
  IS 
  BEGIN
    RETURN '"' || write_string(p_field) || '"'||g_delimeter;
  END;
  
  FUNCTION write_csv(p_field IN NUMBER) RETURN VARCHAR2
  IS
  BEGIN
    RETURN write_string(p_field) || g_delimeter;
  END;
  
  FUNCTION write_csv(p_field IN DATE) RETURN VARCHAR2
  IS
  BEGIN
    RETURN write_string(p_field) || g_delimeter;
  END;  
  
END;
/