-- /packages/intranet-bug-tracker/sql/postgresql/intranet-bug-tracker-drop.sql
--
-- Copyright (c) 2003-2006 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com


alter table im_timesheet_tasks drop column bt_bug_id;


select im_menu__del_module('intranet-bug-tracker');
select im_component_plugin__del_module('intranet-bug-tracker');

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


alter table im_projects drop column bt_project_id;
alter table im_projects drop column bt_component_id;
alter table im_projects drop column bt_found_in_version_id;
alter table im_projects drop column bt_fix_for_version_id;

