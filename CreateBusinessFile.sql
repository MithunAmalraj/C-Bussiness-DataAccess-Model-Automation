/****** Object:  StoredProcedure [dbo].[sp_CreateBusinessFile]    Script Date: 02-06-2019 20:38:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_CreateBusinessFile 'tbl_Country'
ALTER procedure [dbo].[sp_CreateBusinessFile]
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

	select @sqlstring = @sqlstring + 'using System;'																					+ char(13)							
	select @sqlstring = @sqlstring + 'using System.Collections.Generic;'																+ char(13)		
	select @sqlstring = @sqlstring + 'using System.Threading.Tasks;'																	+ char(13)		
	select @sqlstring = @sqlstring + 'using ' + db_name() + '.Repository;'																+ char(13)
	select @sqlstring = @sqlstring + 'using ' + db_name() + '.Utilities;'																+ char(13)
	select @sqlstring = @sqlstring + 'using ' + db_name() + '.Models;'																	+ char(13) + char(13)

	select @sqlstring = @sqlstring + 'namespace ' + db_name() + '.Business'																+ char(13)
	select @sqlstring = @sqlstring + '{'																								+ char(13)
	select @sqlstring = @sqlstring + '	public class ' + @ModelName + 'Manager'															+ char(13)
	select @sqlstring = @sqlstring + '  {'																								+ char(13)
    select @sqlstring = @sqlstring + '		GenericResponse GR = new GenericResponse();'												+ char(13)
    select @sqlstring = @sqlstring + '		Logging _logger = new Logging();'															+ char(13)	+ char(13)

	select @sqlstring = @sqlstring + '		private ' + @ModelName + 'Repository _' + @normalizedmodelname + 'Repository;'				+ char(13)  + char(13)

    select @sqlstring = @sqlstring + '		public ' + @ModelName + 'Manager(string connectionString)'									+ char(13)
    select @sqlstring = @sqlstring + '		{'																							+ char(13)
    select @sqlstring = @sqlstring + '			try'																					+ char(13)
    select @sqlstring = @sqlstring + '		    {'																						+ char(13)
    select @sqlstring = @sqlstring + '				this._' + @normalizedmodelname + 'Repository = new ' + @ModelName + 'Repository(connectionString);'													+ char(13)
    select @sqlstring = @sqlstring + '		    }'																						+ char(13)
    select @sqlstring = @sqlstring + '		    catch (Exception ex)'																	+ char(13)
    select @sqlstring = @sqlstring + '		    {'																						+ char(13)
    select @sqlstring = @sqlstring + '				_logger.LogErrorDAL(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'			+ char(13)
    select @sqlstring = @sqlstring + '		    }'																						+ char(13)
    select @sqlstring = @sqlstring + '		}'																							+ char(13) + char(13)

	select @sqlstring = @sqlstring + '    public GenericResponse Create' + @ModelName + '(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'								+ char(13)
    select @sqlstring = @sqlstring + '    {'																							+ char(13)
    select @sqlstring = @sqlstring + '        try'																						+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogDataBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'			+ char(13)
    select @sqlstring = @sqlstring + '            return _' + @normalizedmodelname + 'Repository.Create' + @ModelName + '(' + @normalizedmodelname + 'Obj, Mode, Mode1);'								+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '        catch (Exception ex)'																		+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogErrorBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'				+ char(13)
    select @sqlstring = @sqlstring + '            return null;'																			+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '    }'																							+ char(13)
    select @sqlstring = @sqlstring + '    public GenericResponse Update' + @ModelName + '(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'								+ char(13)
    select @sqlstring = @sqlstring + '    {'																							+ char(13)
    select @sqlstring = @sqlstring + '        try'																						+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogDataBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'			+ char(13)
    select @sqlstring = @sqlstring + '            return _' + @normalizedmodelname + 'Repository.Update' + @ModelName + '(' + @normalizedmodelname + 'Obj, Mode, Mode1);'								+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '        catch (Exception ex)'																		+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogErrorBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'				+ char(13)
    select @sqlstring = @sqlstring + '            return null;'																			+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '    }'																							+ char(13)
    select @sqlstring = @sqlstring + '    public GenericResponse Delete' + @ModelName + '(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'								+ char(13)
    select @sqlstring = @sqlstring + '    {'																							+ char(13)
    select @sqlstring = @sqlstring + '        try'																						+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogDataBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'			+ char(13)
    select @sqlstring = @sqlstring + '            return _' + @normalizedmodelname + 'Repository.Delete' + @ModelName + '(' + @normalizedmodelname + 'Obj, Mode, Mode1);'								+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '        catch (Exception ex)'																		+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogErrorBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'				+ char(13)
    select @sqlstring = @sqlstring + '            return null;'																			+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '    }'																							+ char(13)
    select @sqlstring = @sqlstring + '    public IList<' + @ModelName + '> Get' + @ModelName + '(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'						+ char(13)
    select @sqlstring = @sqlstring + '    {'																							+ char(13)
    select @sqlstring = @sqlstring + '        try'																						+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogDataBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'			+ char(13)
    select @sqlstring = @sqlstring + '            return _' + @normalizedmodelname + 'Repository.Get' + @ModelName + '(' + @normalizedmodelname + 'Obj, Mode, Mode1);'									+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '        catch (Exception ex)'																		+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogErrorBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'				+ char(13)
    select @sqlstring = @sqlstring + '            return null;'																			+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '    }'																							+ char(13)
    select @sqlstring = @sqlstring + '    public ' + @ModelName + ' GetA' + @ModelName + '(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'								+ char(13)
    select @sqlstring = @sqlstring + '    {'																							+ char(13)
    select @sqlstring = @sqlstring + '        try'																						+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogDataBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'			+ char(13)
    select @sqlstring = @sqlstring + '            return _' + @normalizedmodelname + 'Repository.GetA' + @ModelName + '(' + @normalizedmodelname + 'Obj, Mode, Mode1);'									+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '        catch (Exception ex)'																		+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogErrorBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'				+ char(13)
    select @sqlstring = @sqlstring + '            return null;'																			+ char(13)		
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '    }'																							+ char(13)
    select @sqlstring = @sqlstring + '    public async Task<GenericResponse> Create' + @ModelName + 'Async(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'				+ char(13)
    select @sqlstring = @sqlstring + '    {'																							+ char(13)
    select @sqlstring = @sqlstring + '        try'																						+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogDataBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'			+ char(13)
    select @sqlstring = @sqlstring + '            return await _' + @normalizedmodelname + 'Repository.Create' + @ModelName + 'Async(' + @normalizedmodelname + 'Obj, Mode, Mode1);'					+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '        catch (Exception ex)'																		+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogErrorBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'				+ char(13)
    select @sqlstring = @sqlstring + '            return null;'																			+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '    }'																							+ char(13)
    select @sqlstring = @sqlstring + '    public async Task<GenericResponse> Update' + @ModelName + 'Async(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'				+ char(13)
    select @sqlstring = @sqlstring + '    {'																							+ char(13)
    select @sqlstring = @sqlstring + '        try'																						+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogDataBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'			+ char(13)
    select @sqlstring = @sqlstring + '            return await _' + @normalizedmodelname + 'Repository.Update' + @ModelName + 'Async(' + @normalizedmodelname + 'Obj, Mode, Mode1);'					+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '        catch (Exception ex)'																		+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogErrorBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'				+ char(13)
    select @sqlstring = @sqlstring + '            return null;'																			+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '    }'																							+ char(13)
    select @sqlstring = @sqlstring + '    public async Task<GenericResponse> Delete' + @ModelName + 'Async(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'				+ char(13)
    select @sqlstring = @sqlstring + '    {'																							+ char(13)
    select @sqlstring = @sqlstring + '        try'																						+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogDataBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'			+ char(13)
    select @sqlstring = @sqlstring + '            return await _' + @normalizedmodelname + 'Repository.Delete' + @ModelName + 'Async(' + @normalizedmodelname + 'Obj, Mode, Mode1);'					+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '        catch (Exception ex)'																		+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogErrorBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'				+ char(13)
    select @sqlstring = @sqlstring + '            return null;'																			+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '    }'																							+ char(13)
    select @sqlstring = @sqlstring + '    public async Task<IEnumerable<' + @ModelName + '>> Get' + @ModelName + 'Async(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'	+ char(13)
    select @sqlstring = @sqlstring + '    {'																							+ char(13)
    select @sqlstring = @sqlstring + '        try'																						+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogDataBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'			+ char(13)
    select @sqlstring = @sqlstring + '            return await _' + @normalizedmodelname + 'Repository.Get' + @ModelName + 'Async(' + @normalizedmodelname + 'Obj, Mode, Mode1);'						+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '        catch (Exception ex)'																		+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogErrorBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'				+ char(13)
    select @sqlstring = @sqlstring + '            return null;'																			+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '    }'																							+ char(13)
    select @sqlstring = @sqlstring + '    public async Task<' + @ModelName + '> GetA' + @ModelName + 'Async(' + @ModelName + ' ' + @normalizedmodelname + 'Obj, string Mode, string Mode1)'				+ char(13)
    select @sqlstring = @sqlstring + '    {'																							+ char(13)
    select @sqlstring = @sqlstring + '        try'																						+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogDataBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ' + @normalizedmodelname + 'Obj, "Mode:" + Mode + "," + "Mode1" + Mode1);'			+ char(13)
    select @sqlstring = @sqlstring + '            return await _' + @normalizedmodelname + 'Repository.GetA' + @ModelName + 'Async(' + @normalizedmodelname + 'Obj, Mode, Mode1);'						+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '        catch (Exception ex)'																		+ char(13)
    select @sqlstring = @sqlstring + '        {'																						+ char(13)
    select @sqlstring = @sqlstring + '            _logger.LogErrorBO(this.GetType().Namespace, this.GetType().Name, System.Reflection.MethodBase.GetCurrentMethod().Name, "", "", ex, "");'				+ char(13)
    select @sqlstring = @sqlstring + '            return null;'																			+ char(13)
    select @sqlstring = @sqlstring + '        }'																						+ char(13)
    select @sqlstring = @sqlstring + '    }'																							+ char(13)
    select @sqlstring = @sqlstring + '	}'																								+ char(13)
	select @sqlstring = @sqlstring + '}'																								+ char(13)

	select @sqlstring

END