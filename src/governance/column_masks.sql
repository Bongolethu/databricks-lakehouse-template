CREATE OR REPLACE FUNCTION main.governance.email_mask(email STRING)
RETURN CASE 
  -- Grant explicit unmasked visibility to core data engineers and technical analysts
  WHEN is_account_group_member('data_developers') THEN email
  WHEN is_account_group_member('technical_analysts') THEN email
  -- Obfuscate string data by default for standard users, BAs, and LLM automation contexts
  ELSE regexp_replace(email, '(?<=.)[^@](?=[^@]*?[^@]\.)', '*')
END;