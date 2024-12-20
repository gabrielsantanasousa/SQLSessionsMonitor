-- Cria tabela dbo.sessions_dba

if object_id('dbo.sessions_dba') is not null
begin
print 'tabela dbo.sessions_dba existe, executando drop'
drop table dbo.sessions_dba;
end
go

create table dbo.sessions_dba
(
id int identity (1,1) not null,
LoadDate datetime not null,
UPdateDate datetime,
host_name varchar(60), 
program_name varchar(500), 
client_interface_name varchar(500), 
login_name varchar(120), 
original_login_name varchar(120),
database_name varchar(200)
constraint PKSessions_dba primary key (id,LoadDate)
)
go

alter table dbo.sessions_dba add constraint Defsessions_dba default getdate() for LoadDate
go


-- Merge com CTE para alimentar a tabela

with cteSessoes 
as
(
select distinct host_name, 
program_name, 
client_interface_name, 
login_name, 
original_login_name,
db_name(database_id) database_name
from sys.dm_exec_sessions with (nolock)
where program_name is not null
and client_interface_name is not null
and program_name not in (' ')
)
MERGE 
    dbo.sessions_dba AS Destino
USING 
   cteSessoes AS Origem ON (
Origem.host_name = Destino.host_name  
and Origem.program_name = Destino.program_name 
and Origem.client_interface_name = Destino.client_interface_name
and Origem.login_name = Destino.login_name 
and Origem.original_login_name = Destino.original_login_name 
and Origem.database_name = Destino.database_name
and Origem.host_name is not null 
and Origem.program_name is not null 
and Origem.client_interface_name is not null
and Origem.host_name  not in (' ') 
and Origem.program_name not in (' ')
)

-- Registro existe, execute update na tabela Destino
WHEN MATCHED and  (Origem.host_name is not null and Origem.program_name is not null and Origem.client_interface_name is not null and Origem.host_name  not in (' ') and Origem.program_name not in (' ')) THEN
    UPDATE SET 
        Destino.UPdateDate = getdate(),
        Destino.host_name = Origem.host_name,
        Destino.program_name = Origem.program_name,
        Destino.client_interface_name = Origem.client_interface_name,
Destino.login_name = Origem.login_name,
Destino.original_login_name = Origem.original_login_name,
Destino.database_name = Origem.database_name

-- Registro não existe na tabela Destino, executa o insert
WHEN NOT MATCHED and  ( Origem.host_name is not null and Origem.program_name is not null and Origem.client_interface_name is not null) THEN
    INSERT (LoadDate,host_name,program_name,client_interface_name,login_name,original_login_name,database_name) 
    VALUES(getdate(),Origem.host_name,Origem.program_name,Origem.client_interface_name,Origem.login_name,Origem.original_login_name,Origem.database_name);