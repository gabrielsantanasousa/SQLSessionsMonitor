
SQLSessionsMonitor

Script T-SQL com um Merge Join para monitorar sessões da DMV sys.dm_exec_sessions.

O Merge join carrga a coluna LoadDate no primeiro insert, caso a mesma sessão se repita faz um update carregando a coluna LoadDate.

Muito útil para monitor histórico de sessões sem ocupar espaço tendo a primeira data da sessão e a constância de utilização da mesma.

