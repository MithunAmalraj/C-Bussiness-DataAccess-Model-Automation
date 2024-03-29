/****** Object:  StoredProcedure [dbo].[sp_CreateRepositoryFile]    Script Date: 02-06-2019 20:39:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_CreateRepositoryFile 'tbl_Status'
ALTER procedure [dbo].[sp_CreateRepositoryFile]
	@TableName			varchar(300) = ''
AS
BEGIN


declare 
	@sqlstring varchar(max) = '',
	@PrimaryColumnName		varchar(500),
	@ColumnName				varchar(500),
	@ColumnType				varchar(100),
	@IsLengthField			bit,
	@LengthValue			varchar(100),
	@Precision				varchar(10),
	@Scale					varchar(10),
	@IsNullField			bit,
	@IsPrimaryKey			bit,
	@IsIdentity				bit,
	@ColumnCount			int = 0,
	@count					int = 1,
	@normalizedcolumnname	varchar(500) = '',
	@normalizedmodelname		varchar(500) = '',
	@ModelName				varchar(300)=''
	
	set @ModelName = substring(@TableName,5,LEN(@TableName))
	set @normalizedmodelname = LOWER(@ModelName)

	select @sqlstring = @sqlstring + 'using Dapper;'																					+ char(13)
	select @sqlstring = @sqlstring + 'using System;'																					+ char(13)
	select @sqlstring = @sqlstring + 'using System.Collections.Generic;'																+ char(13)
	select @sqlstring = @sqlstring + 'using System.Data.SqlClient;'																		+ char(13)
	select @sqlstring = @sqlstring + 'using System.Linq;'																				+ char(13)
	select @sqlstring = @sqlstring + 'using static System.Data.CommandType;'															+ char(13)
	select @sqlstring = @sqlstring + 'using System.Data;'																				+ char(13)
	select @sqlstring = @sqlstring + 'using System.Threading.Tasks;'																	+ char(13)
	select @sqlstring = @sqlstring + 'using '+db_name()+'.Utilities;'																	+ char(13)
	select @sqlstring = @sqlstring + 'using '+db_name()+'.Models;'																		+ char(13)

	select @sqlstring = @sqlstring + 'namespace '+db_name()+'.Repository'																+ char(13)
	select @sqlstring = @sqlstring + '{'																								+ char(13)
	select @sqlstring = @sqlstring + '	public class ' + @ModelName + 'Repository : BaseRepositry'										+ char(13)
	select @sqlstring = @sqlstring + '  {'																								+ char(13)
    select @sqlstring = @sqlstring + '		static string ProcedureName = "po_' + @ModelName + '";'										+ char(13)
    select @sqlstring = @sqlstring + '		SqlConnection con = new SqlConnection();'													+ char(13)
    select @sqlstring = @sqlstring + '		GenericResponse GR = new GenericResponse();'												+ char(13)
    select @sqlstring = @sqlstring + '		Logging _logger = new Logging();'															+ char(13)	+ char(13)

	select @sqlstring = @sqlstring + '		private string connectionString;'															+ char(13)  + char(13)

    select @sqlstring = @sqlstring + '		public ' + @ModelName + 'Repository(string connectionString)'														+ char(13)
    select @sqlstring = @sqlstring + '		{'																							+ char(13)
    select @sqlstring = @sqlstring + '			try'																					+ char(13)
    select @sqlstring = @sqlstring + '		    {'																						+ char(13)
    select @sqlstring = @sqlstring + '				this.connectionString = connectionString;'											+ char(13)
    select @sqlstring = @sqlstring + '				con = new SqlConnection(connectionString);'											+ char(13)
    select @sqlstring = @sqlstring + '		    }'																						+ char(13)
    select @sqlstring = @sqlstring + '		    catch (Exception ex)'																	+ char(13)
    select @sqlstring = @sqlstring + '		    {'																						+ char(13)
    select @sqlstring = @sqlstring + '				_logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'																	+ char(13)
    select @sqlstring = @sqlstring + '		    }'																						+ char(13)
    select @sqlstring = @sqlstring + '		}'																							+ char(13) + char(13)

    select @sqlstring = @sqlstring + '		public DynamicParameters GetParameters('+@ModelName+' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'																									+ char(13)
    select @sqlstring = @sqlstring + '		{'																							+ char(13)
    select @sqlstring = @sqlstring + '			try'																					+ char(13)
    select @sqlstring = @sqlstring + '		    {'																						+ char(13)
    select @sqlstring = @sqlstring + '				_logger.LogDataDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);' + char(13)
    select @sqlstring = @sqlstring + '		        DynamicParameters parameters = new DynamicParameters();'							+ char(13)

	IF(ISNULL(@TableName,'') <> '')
	BEGIN
		IF(OBJECT_ID('tempdb..#tmp_Columns') IS NOT NULL)
			drop table #tmp_Columns

		create table #tmp_Columns(ColumnName varchar(500),ColumnType varchar(100),LengthValue varchar(100),Precision varchar(10),Scale varchar(10), IsNullField bit, IsPrimaryKey bit,IsIdentity bit)

		insert into #tmp_Columns select col.name,t.name,col.max_length,col.precision,col.scale,col.is_nullable,pk.column_id,col.is_identity
			from sys.tables as tab
				left join sys.columns as col
					on tab.object_id = col.object_id
				left join sys.types as t
					on col.user_type_id = t.user_type_id
				left join sys.default_constraints as def
					on def.object_id = col.default_object_id
				left join (
						select index_columns.object_id, 
								index_columns.column_id
						from sys.index_columns
								inner join sys.indexes 
									on index_columns.object_id = indexes.object_id
								and index_columns.index_id = indexes.index_id
						where indexes.is_primary_key = 1
						) as pk 
				on col.object_id = pk.object_id and col.column_id = pk.column_id
			where tab.name = @TableName
		
		
		declare c1 cursor for select * from #tmp_Columns
		open c1
		fetch c1 into 	
			@ColumnName,
			@ColumnType,
			@LengthValue,
			@Precision,
			@Scale,
			@IsNullField,
			@IsPrimaryKey,
			@IsIdentity
		while(@@FETCH_STATUS=0)
		begin
			
			select @normalizedcolumnname =  replace(@ColumnName,'txt_','')
			select @normalizedcolumnname =  replace(@normalizedcolumnname,'int_','')
			select @normalizedcolumnname =  replace(@normalizedcolumnname,'chr_','')
			select @normalizedcolumnname =  replace(@normalizedcolumnname,'dte_','')
			select @normalizedcolumnname =  replace(@normalizedcolumnname,'rwv_','')
			select @normalizedcolumnname =  replace(@normalizedcolumnname,'is_','')
			select @normalizedcolumnname =  replace(@normalizedcolumnname,'hsh_','')
			select @normalizedcolumnname =  replace(@normalizedcolumnname,'enc_','')
			select @normalizedcolumnname =  replace(@normalizedcolumnname,'bit_','')
			select @normalizedcolumnname =  replace(@normalizedcolumnname,'vrb_','')
			select @normalizedcolumnname =  replace(@normalizedcolumnname,'flt_','')
			select @normalizedcolumnname =  replace(@normalizedcolumnname,'dcm_','')
			select @normalizedcolumnname =  replace(@normalizedcolumnname,'_',' ')

			select @sqlstring = @sqlstring + '        parameters.Add("@' + @ColumnName + '", ' + @normalizedmodelname + 'Obj.' + @normalizedcolumnname + ');' + char(13)

			fetch c1 into 	
				@ColumnName,
				@ColumnType,
				@LengthValue,
				@Precision,
				@Scale,
				@IsNullField,
				@IsPrimaryKey,
				@IsIdentity
		end
		close c1
		deallocate c1

		select @sqlstring = @sqlstring + '		parameters.Add("@ind", Mode);'															+ char(13)
        select @sqlstring = @sqlstring + '      parameters.Add("@ind1", Mode1);'														+ char(13)
        select @sqlstring = @sqlstring + '      parameters.Add("@msg", dbType: DbType.String, size: 500, direction: ParameterDirection.Output);'+ char(13)
        select @sqlstring = @sqlstring + '      parameters.Add("@error_Code", dbType: DbType.Int32, direction: ParameterDirection.Output);'+ char(13)
        select @sqlstring = @sqlstring + '      parameters.Add("@new_Id", dbType: DbType.Int32, direction: ParameterDirection.Output);'+ char(13)
        select @sqlstring = @sqlstring + '      parameters.Add("@return", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);'+ char(13)
        select @sqlstring = @sqlstring + '      return parameters;'																		+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '    catch (Exception ex)'																		+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'+ char(13)
        select @sqlstring = @sqlstring + '        return null;'																			+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '}'																							+ char(13)
        select @sqlstring = @sqlstring + 'public GenericResponse Create'+@ModelName+'('+@ModelName+' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'+ char(13)
        select @sqlstring = @sqlstring + '{'																							+ char(13)
        select @sqlstring = @sqlstring + '    try'																						+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogDataDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'+ char(13)
        select @sqlstring = @sqlstring + '        DynamicParameters parameters = new DynamicParameters();'								+ char(13)
        select @sqlstring = @sqlstring + '        parameters = GetParameters(' + @normalizedmodelname + 'Obj, Mode, Mode1);'			+ char(13)
        select @sqlstring = @sqlstring + '        SqlMapper.Execute(con, ProcedureName, parameters, null, 0, StoredProcedure);'			+ char(13)+ char(13)

        select @sqlstring = @sqlstring + '        if (parameters.Get<string>("msg") != null)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnMessage = parameters.Get<string>("msg");'								+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnMessage = "";'															+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int>("error_Code") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ErrorCode = parameters.Get<int>("error_Code");'								+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ErrorCode = 0;'																+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int?>("new_Id") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.NewId = parameters.Get<int>("new_Id");'										+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.NewId = 0;'																	+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int?>("return") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnValue = parameters.Get<int>("return");'									+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnValue = 0;'																+ char(13)
        select @sqlstring = @sqlstring + '        if (GR.ReturnValue == 1)'																+ char(13)
        select @sqlstring = @sqlstring + '        {'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.IsSuccess = true;'																+ char(13)
        select @sqlstring = @sqlstring + '            return GR;'																		+ char(13)
        select @sqlstring = @sqlstring + '        }'																					+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '        {'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.IsSuccess = false;'															+ char(13)
        select @sqlstring = @sqlstring + '            return GR;'																		+ char(13)
        select @sqlstring = @sqlstring + '        }'																					+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '    catch (Exception ex)'																		+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'+ char(13)
        select @sqlstring = @sqlstring + '        return null;'																			+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '}'																							+ char(13)
        select @sqlstring = @sqlstring + 'public GenericResponse Update' + @ModelName + '(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'+ char(13)
        select @sqlstring = @sqlstring + '{'																							+ char(13)
        select @sqlstring = @sqlstring + '    try'																						+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogDataDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'+ char(13)
        select @sqlstring = @sqlstring + '        DynamicParameters parameters = new DynamicParameters();'								+ char(13)
        select @sqlstring = @sqlstring + '        parameters = GetParameters(' + @normalizedmodelname + 'Obj, Mode, Mode1);'			+ char(13)
        select @sqlstring = @sqlstring + '        SqlMapper.Execute(con, ProcedureName, parameters, null, 0, StoredProcedure);'			+ char(13) + char(13)

        select @sqlstring = @sqlstring + '        if (parameters.Get<string>("msg") != null)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnMessage = parameters.Get<string>("msg");'								+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnMessage = "";'															+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int>("error_Code") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ErrorCode = parameters.Get<int>("error_Code");'								+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ErrorCode = 0;'																+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int?>("new_Id") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '           GR.NewId = parameters.Get<int>("new_Id");'											+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.NewId = 0;'																	+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int?>("return") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnValue = parameters.Get<int>("return");'									+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '           GR.ReturnValue = 0;'																+ char(13)
        select @sqlstring = @sqlstring + '        if (GR.ReturnValue == 1)'																+ char(13)
        select @sqlstring = @sqlstring + '        {'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.IsSuccess = true;'																+ char(13)
        select @sqlstring = @sqlstring + '            return GR;'																		+ char(13)
        select @sqlstring = @sqlstring + '        }'																					+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '        {'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.IsSuccess = false;'															+ char(13)
        select @sqlstring = @sqlstring + '            return GR;'																		+ char(13)
        select @sqlstring = @sqlstring + '        }'																					+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '    catch (Exception ex)'																		+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'+ char(13)
        select @sqlstring = @sqlstring + '        return null;'																			+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '}'																							+ char(13)
        select @sqlstring = @sqlstring + 'public GenericResponse Delete' + @ModelName + '(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'+ char(13)
        select @sqlstring = @sqlstring + '{'																							+ char(13)
        select @sqlstring = @sqlstring + '    try'																						+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogDataDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'+ char(13)
        select @sqlstring = @sqlstring + '        DynamicParameters parameters = new DynamicParameters();'								+ char(13)
        select @sqlstring = @sqlstring + '        parameters = GetParameters(' + @normalizedmodelname + 'Obj, Mode, Mode1);'			+ char(13)
        select @sqlstring = @sqlstring + '        SqlMapper.Execute(con, ProcedureName, parameters, null, 0, StoredProcedure);'			+ char(13) + char(13)

        select @sqlstring = @sqlstring + '        if (parameters.Get<string>("msg") != null)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnMessage = parameters.Get<string>("msg");'								+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnMessage = "";'															+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int>("error_Code") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ErrorCode = parameters.Get<int>("error_Code");'								+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ErrorCode = 0;'																+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int?>("new_Id") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.NewId = parameters.Get<int>("new_Id");'										+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.NewId = 0;'																	+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int?>("return") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnValue = parameters.Get<int>("return");'									+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnValue = 0;'																+ char(13)
        select @sqlstring = @sqlstring + '        if (GR.ReturnValue == 1)'																+ char(13)
        select @sqlstring = @sqlstring + '        {'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.IsSuccess = true;'																+ char(13)
        select @sqlstring = @sqlstring + '            return GR;'																		+ char(13)
        select @sqlstring = @sqlstring + '        }'																					+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '        {'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.IsSuccess = false;'															+ char(13)
        select @sqlstring = @sqlstring + '            return GR;'																		+ char(13)
        select @sqlstring = @sqlstring + '        }'																					+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '    catch (Exception ex)'																		+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'+ char(13)
        select @sqlstring = @sqlstring + '        return null;'																			+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '}'																							+ char(13)
        select @sqlstring = @sqlstring + 'public IList<' + @ModelName + '> Get' + @ModelName + '(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'+ char(13)
        select @sqlstring = @sqlstring + '{'																							+ char(13)
        select @sqlstring = @sqlstring + '    try'																						+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogDataDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'+ char(13)
        select @sqlstring = @sqlstring + '        DynamicParameters parameters = new DynamicParameters();'								+ char(13)
        select @sqlstring = @sqlstring + '        parameters = GetParameters(' + @normalizedmodelname + 'Obj, Mode, Mode1);'			+ char(13)
        select @sqlstring = @sqlstring + '        IList<' + @ModelName + '> ' + @ModelName + 'List = SqlMapper.Query<' + @ModelName + '>(con, ProcedureName, parameters, null, false, 100000, StoredProcedure).ToList();'+ char(13)
        select @sqlstring = @sqlstring + '        return ' + @ModelName + 'List;'														+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '    catch (Exception ex)'																		+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'+ char(13)
        select @sqlstring = @sqlstring + '        return null;'																			+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '}'																							+ char(13)
        select @sqlstring = @sqlstring + 'public ' + @ModelName + ' GetA' + @ModelName + '(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'+ char(13)
        select @sqlstring = @sqlstring + '{'																							+ char(13)
        select @sqlstring = @sqlstring + '    try'																						+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogDataDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'+ char(13)
        select @sqlstring = @sqlstring + '        DynamicParameters parameters = new DynamicParameters();'								+ char(13)
        select @sqlstring = @sqlstring + '        parameters = GetParameters(' + @normalizedmodelname + 'Obj, Mode, Mode1);'			+ char(13)
        select @sqlstring = @sqlstring + '        ' + @normalizedmodelname + 'Obj = SqlMapper.Query<' + @ModelName + '>(con, ProcedureName, parameters, null, false, 100000, StoredProcedure).FirstOrDefault();'+ char(13)
        select @sqlstring = @sqlstring + '        return ' + @normalizedmodelname + 'Obj;'												+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '    catch (Exception ex)'																		+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'+ char(13)
        select @sqlstring = @sqlstring + '        return null;'																			+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '}'																							+ char(13)
        select @sqlstring = @sqlstring + 'public async Task<GenericResponse> Create' + @ModelName + 'Async(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'+ char(13)
        select @sqlstring = @sqlstring + '{'																							+ char(13)
        select @sqlstring = @sqlstring + '    try'																						+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogDataDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'+ char(13)
        select @sqlstring = @sqlstring + '        DynamicParameters parameters = new DynamicParameters();'								+ char(13)
        select @sqlstring = @sqlstring + '        parameters = GetParameters(' + @normalizedmodelname + 'Obj, Mode, Mode1);'			+ char(13)
        select @sqlstring = @sqlstring + '        await SqlMapper.ExecuteAsync(con, ProcedureName, parameters, null, 0, StoredProcedure);'+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<string>("msg") != null)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnMessage = parameters.Get<string>("msg");'								+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnMessage = "";'															+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int>("error_Code") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ErrorCode = parameters.Get<int>("error_Code");'								+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ErrorCode = 0;'																+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int?>("new_Id") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.NewId = parameters.Get<int>("new_Id");'										+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.NewId = 0;'																	+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int?>("return") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnValue = parameters.Get<int>("return");'									+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnValue = 0;'																+ char(13)
        select @sqlstring = @sqlstring + '        if (GR.ReturnValue == 1)'																+ char(13)
        select @sqlstring = @sqlstring + '        {'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.IsSuccess = true;'																+ char(13)
        select @sqlstring = @sqlstring + '            return GR;'																		+ char(13)
        select @sqlstring = @sqlstring + '        }'																					+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '        {'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.IsSuccess = false;'															+ char(13)
        select @sqlstring = @sqlstring + '            return GR;'																		+ char(13)
        select @sqlstring = @sqlstring + '        }'																					+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '    catch (Exception ex)'																		+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'+ char(13)
        select @sqlstring = @sqlstring + '        return null;'																			+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '}'																							+ char(13)
        select @sqlstring = @sqlstring + 'public async Task<GenericResponse> Update' + @ModelName + 'Async(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'+ char(13)
        select @sqlstring = @sqlstring + '{'																							+ char(13)
        select @sqlstring = @sqlstring + '    try'																						+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogDataDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'+ char(13)
        select @sqlstring = @sqlstring + '        DynamicParameters parameters = new DynamicParameters();'								+ char(13)
        select @sqlstring = @sqlstring + '        parameters = GetParameters(' + @normalizedmodelname + 'Obj, Mode, Mode1);'			+ char(13)
        select @sqlstring = @sqlstring + '        await SqlMapper.ExecuteAsync(con, ProcedureName, parameters, null, 0, StoredProcedure);'+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<string>("msg") != null)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnMessage = parameters.Get<string>("msg");'								+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnMessage = "";'															+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int>("error_Code") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ErrorCode = parameters.Get<int>("error_Code");'								+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ErrorCode = 0;'																+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int?>("new_Id") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.NewId = parameters.Get<int>("new_Id");'										+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.NewId = 0;'																	+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int?>("return") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnValue = parameters.Get<int>("return");'									+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnValue = 0;'																+ char(13)
        select @sqlstring = @sqlstring + '        if (GR.ReturnValue == 1)'																+ char(13)
        select @sqlstring = @sqlstring + '        {'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.IsSuccess = true;'																+ char(13)
        select @sqlstring = @sqlstring + '            return GR;'																		+ char(13)
        select @sqlstring = @sqlstring + '        }'																					+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '        {'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.IsSuccess = false;'															+ char(13)
        select @sqlstring = @sqlstring + '            return GR;'																		+ char(13)
        select @sqlstring = @sqlstring + '        }'																					+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '    catch (Exception ex)'																		+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'+ char(13)
        select @sqlstring = @sqlstring + '        return null;'																			+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '}'																							+ char(13)
        select @sqlstring = @sqlstring + 'public async Task<GenericResponse> Delete' + @ModelName + 'Async(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'+ char(13)
        select @sqlstring = @sqlstring + '{'																							+ char(13)
        select @sqlstring = @sqlstring + '    try'																						+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogDataDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'+ char(13)
        select @sqlstring = @sqlstring + '        DynamicParameters parameters = new DynamicParameters();'								+ char(13)
        select @sqlstring = @sqlstring + '        parameters = GetParameters(' + @normalizedmodelname + 'Obj, Mode, Mode1);'			+ char(13)
        select @sqlstring = @sqlstring + '        await SqlMapper.ExecuteAsync(con, ProcedureName, parameters, null, 0, StoredProcedure);'+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<string>("msg") != null)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnMessage = parameters.Get<string>("msg");'								+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnMessage = "";'															+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int>("error_Code") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ErrorCode = parameters.Get<int>("error_Code");'								+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ErrorCode = 0;'																+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int?>("new_Id") != 0)'												+ char(13)
        select @sqlstring = @sqlstring + '            GR.NewId = parameters.Get<int>("new_Id");'										+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.NewId = 0;'																	+ char(13)
        select @sqlstring = @sqlstring + '        if (parameters.Get<int?>("return") != 0)'											+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnValue = parameters.Get<int>("return");'									+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.ReturnValue = 0;'																+ char(13)
        select @sqlstring = @sqlstring + '        if (GR.ReturnValue == 1)'																+ char(13)
        select @sqlstring = @sqlstring + '        {'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.IsSuccess = true;'																+ char(13)
        select @sqlstring = @sqlstring + '            return GR;'																		+ char(13)
        select @sqlstring = @sqlstring + '        }'																					+ char(13)
        select @sqlstring = @sqlstring + '        else'																					+ char(13)
        select @sqlstring = @sqlstring + '        {'																					+ char(13)
        select @sqlstring = @sqlstring + '            GR.IsSuccess = false;'															+ char(13)
        select @sqlstring = @sqlstring + '            return GR;'																		+ char(13)
        select @sqlstring = @sqlstring + '        }'																					+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '    catch (Exception ex)'																		+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'+ char(13)
        select @sqlstring = @sqlstring + '        return null;'																			+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '}'																							+ char(13)
        select @sqlstring = @sqlstring + 'public async Task<IEnumerable<' + @ModelName + '>> Get' + @ModelName + 'Async(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'+ char(13)
        select @sqlstring = @sqlstring + '{'																							+ char(13)
        select @sqlstring = @sqlstring + '    try'																						+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogDataDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'+ char(13)
        select @sqlstring = @sqlstring + '        DynamicParameters parameters = new DynamicParameters();'								+ char(13)
        select @sqlstring = @sqlstring + '        parameters = GetParameters(' + @normalizedmodelname + 'Obj, Mode, Mode1);'			+ char(13)
        select @sqlstring = @sqlstring + '        return await SqlMapper.QueryAsync<' + @ModelName + '>(con, ProcedureName, parameters, null, 100000, StoredProcedure);'+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '    catch (Exception ex)'																		+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'+ char(13)
        select @sqlstring = @sqlstring + '        return null;'																			+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '}'																							+ char(13)
        select @sqlstring = @sqlstring + 'public async Task<' + @ModelName + '> GetA' + @ModelName + 'Async(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'+ char(13)
        select @sqlstring = @sqlstring + '{'																							+ char(13)
        select @sqlstring = @sqlstring + '    try'																						+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogDataDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'+ char(13)
        select @sqlstring = @sqlstring + '        DynamicParameters parameters = new DynamicParameters();'								+ char(13)
        select @sqlstring = @sqlstring + '        parameters = GetParameters(' + @normalizedmodelname + 'Obj, Mode, Mode1);'			+ char(13)
        select @sqlstring = @sqlstring + '        return await SqlMapper.QueryFirstOrDefaultAsync<' + @ModelName + '>(con, ProcedureName, parameters, null, 100000, StoredProcedure);'+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '    catch (Exception ex)'																		+ char(13)
        select @sqlstring = @sqlstring + '    {'																						+ char(13)
        select @sqlstring = @sqlstring + '        _logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'+ char(13)
        select @sqlstring = @sqlstring + '       return null;'																			+ char(13)
        select @sqlstring = @sqlstring + '    }'																						+ char(13)
        select @sqlstring = @sqlstring + '}'																							+ char(13)
		select @sqlstring = @sqlstring + '}'																							+ char(13)
		select @sqlstring = @sqlstring + '}'																							+ char(13)

		select @sqlstring

	END
END