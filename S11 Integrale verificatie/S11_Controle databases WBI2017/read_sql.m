close all; clear all; clc;
tic
% PG_settings
fileID='c:\programs\Hydra\databases\GR2017_Benedenmaas_23-1_v01\GR2017_Benedenmaas_23-1_v01.sqlite';
javaaddpath('c:\Repository\OET\matlab\io\sqlite\sqlite-jdbc-3.7.2.jar');
% javaaddpath('c:\Program Files (x86)\SQLite ODBC Driver\sqlite3odbc.dll');
% conn=pg_connectdb(fileID);
% pg_gettables(conn);


% tables = pg_fetch(fileID, 'SELECT tablename FROM pg_tables WHERE schemaname NOT IN (''pg_catalog'',''information_schema'')');


% conn = database(fileID,'','','org.sqlite.JDBC','URL');
% conn = database(fileID,'','','c:\Repository\OET\matlab\io\sqlite\sqlite-jdbc-3.7.2.jar','URL');
% conn = database(fileID,'','','org.sqlite.JDBC','URL');
conn = database(fileID,'','','org.sqlite.JDBC',['jdbc:sqlite:' fileID]);
conn.message

% 'jdbc:sqlite:path\file'

AAA=fetch(conn,'HRDLocations');

close(conn);




toc