/****** Object:  StoredProcedure [dbo].[sp_CreateModelFile]    Script Date: 02-06-2019 20:38:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_CreateModelFile]
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
	@normalizedcolumntype	varchar(100)

	select @sqlstring = @sqlstring + 'using System;' + char(13)
	select @sqlstring = @sqlstring + 'using System.Collections.Generic;' + char(13)
	select @sqlstring = @sqlstring + 'using System.Text;' + char(13) + char(13)

	select @sqlstring = @sqlstring + 'namespace '+db_name()+'.Models' + char(13)
	select @sqlstring = @sqlstring + '{' + char(13)
	select @sqlstring = @sqlstring + '    public class '+substring(@TableName,5,LEN(@TableName))+'' + char(13)
	select @sqlstring = @sqlstring + '    {' + char(13)

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


			if(@ColumnType in ('int'))
				select @normalizedcolumntype = 'int'
			else if(@ColumnType in ('tinyint'))
				select @normalizedcolumntype = 'Byte'
			else if(@ColumnType in ('bigint'))
				select @normalizedcolumntype = 'Int64'
			else if(@ColumnType in ('decimal'))
				select @normalizedcolumntype = 'decimal'
			else if(@ColumnType in ('bit'))
				select @normalizedcolumntype = 'bool'
			else if(@ColumnType in ('float'))
				select @normalizedcolumntype = 'double'
			else if(@ColumnType in ('varchar','char','nvarchar'))
				select @normalizedcolumntype = 'string'
			else if(@ColumnType in ('datetime','date'))
				select @normalizedcolumntype = 'DateTime?'

			select @sqlstring = @sqlstring + '        public ' + @normalizedcolumntype + ' '+@normalizedcolumnname+' { get; set; }' + char(13)

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

		select @sqlstring = @sqlstring + '    }' + char(13)
		select @sqlstring = @sqlstring + '}' + char(13)
		select @sqlstring

	END
END