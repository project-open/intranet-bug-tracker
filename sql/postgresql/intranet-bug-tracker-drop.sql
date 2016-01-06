-- /packages/intranet-bug-tracker/sql/postgresql/intranet-bug-tracker-drop.sql
--
-- Copyright (c) 2003-2006 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com


select im_menu__del_module('intranet-bug-tracker');
select im_component_plugin__del_module('intranet-bug-tracker');


create or replace function inline_0 ()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_timesheet_tasks' and lower(column_name) = 'bt_bug_id';
	IF v_count > 0 THEN
		alter table im_timesheet_tasks drop column bt_bug_id cascade;
		-- NOTICE:  drop cascades to view im_timesheet_tasks_view
	END IF;

	RETURN 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();



-- Delete im_timesheet_tasks.bt_bug_id.
-- In order to delete the attribute, we need to 
-- recreate dependent views:
--
drop view if exists im_timesheet_tasks_view;
create or replace view im_timesheet_tasks_view as
select  t.*,
        p.parent_id as project_id,
        p.project_name as task_name,
        p.project_nr as task_nr,
        p.percent_completed,
        p.project_type_id as task_type_id,
        p.project_status_id as task_status_id,
        p.start_date,
        p.end_date,
        p.reported_hours_cache,
        p.reported_days_cache,
        p.reported_hours_cache as reported_units_cache
from
        im_projects p,
        im_timesheet_tasks t
where
        t.task_id = p.project_id;


-- Remove BT Container Project Types
-- Set project_type to "Other" from "Bug Tracker Container"
-- or "Bug Tracker Task"
update im_projects
set project_type_id = 85
where project_type_id in (4300, 4305);

delete from im_category_hierarchy where parent_id in (4300, 4305) or child_id in (4300, 4305);
delete from im_dynfield_type_attribute_map where object_type_id in (4300, 4305);
delete from im_categories where category_id in (4300, 4305);



-- Fix dynfield widget delete function
create or replace function im_dynfield_widget__delete (integer)
returns integer as $body$
DECLARE
        p_widget_id             alias for $1;
BEGIN
        -- Erase the im_dynfield_widgets item associated with the id
        delete from im_dynfield_widgets
        where widget_id = p_widget_id;

        -- Erase all the privileges
        delete from acs_permissions
        where object_id = p_widget_id;

        PERFORM acs_object__delete(p_widget_id);
        return 0;
end;$body$ language 'plpgsql';




select im_dynfield_widget__delete (
       (select widget_id from im_dynfield_widgets where widget_name = 'bt_project')
);
select im_dynfield_widget__delete (
       (select widget_id from im_dynfield_widgets where widget_name = 'bt_component')
);
select im_dynfield_widget__delete (
       (select widget_id from im_dynfield_widgets where widget_name = 'bt_components')
);
select im_dynfield_widget__delete (
       (select widget_id from im_dynfield_widgets where widget_name = 'bt_version')
);





create or replace function inline_0 ()
returns integer as $body$
DECLARE
	v_count		integer;
BEGIN
	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_timesheet_tasks' and lower(column_name) = 'bt_component_id';
	IF v_count > 0 THEN
		alter table im_timesheet_tasks drop column bt_component_id cascade;
	END IF;

	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_projects' and lower(column_name) = 'bt_project_id';
	IF v_count > 0 THEN
		alter table im_projects drop column bt_project_id cascade;
	END IF;

	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_projects' and lower(column_name) = 'bt_found_in_version_id';
	IF v_count > 0 THEN
		alter table im_projects drop column bt_found_in_version_id cascade;
	END IF;

	select count(*) into v_count from user_tab_columns
	where lower(table_name) = 'im_projects' and lower(column_name) = 'bt_fix_for_version_id';
	IF v_count > 0 THEN
		alter table im_projects drop column bt_fix_for_version_id;
	END IF;

	RETURN 0;
END;$body$ language 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();


