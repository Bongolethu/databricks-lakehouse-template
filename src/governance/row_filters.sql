CREATE OR REPLACE FUNCTION main.governance.region_isolation_filter(region_id STRING)
RETURN is_account_group_member('solution_architects') 
    OR is_account_group_member(concat('region_access_', region_id));