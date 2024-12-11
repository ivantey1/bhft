WITH exchange_fees_base AS (
    SELECT 
        trace_id,
        platform_time,
        message::json->'data'->'result'->0 AS trade_data
    FROM dump_log
),
exchange_fees_calculated AS (
    SELECT 
        trace_id,
        (COALESCE((trade_data->>'fee')::numeric, 0) + 
         COALESCE((trade_data->>'gt_fee')::numeric, 0) + 
         COALESCE((trade_data->>'rebated_fee')::numeric, 0)) AS exchange_fee,
        (trade_data->>'fee_currency') AS fee_currency,
        (trade_data->>'currency_pair') AS currency_pair,
        split_part((trade_data->>'currency_pair'), '_', 1) AS base_asset,
        split_part((trade_data->>'currency_pair'), '_', 2) AS quote_asset
    FROM exchange_fees_base
),
platform_fees AS (
    SELECT 
        trace_id,
        platform_time,
        side,
        role,
        fee_amount AS platform_fee,
        fee_asset_name,
        base_asset_name,
        quote_asset_name
    FROM own_trade_log
),
final_data AS (
    SELECT DISTINCT ON (p.trace_id)
        p.trace_id,
        p.platform_time,
        p.side AS "Side",
        p.role AS "Role",
        p.platform_fee AS "Platform rate/-s",
        CASE 
            WHEN p.fee_asset_name = p.base_asset_name THEN 'base'
            WHEN p.fee_asset_name = p.quote_asset_name THEN 'quote'
            ELSE 'aux'
        END AS "Platform asset",
        e.exchange_fee AS "Exchange rate/-s",
        CASE 
            WHEN e.fee_currency = e.base_asset THEN 'base'
            WHEN e.fee_currency = e.quote_asset THEN 'quote'
            ELSE 'aux'
        END AS "Exchange asset",
        ABS(COALESCE(p.platform_fee, 0) - COALESCE(e.exchange_fee, 0)) AS fee_difference
    FROM platform_fees p
    LEFT JOIN exchange_fees_calculated e 
        ON p.trace_id = e.trace_id
    ORDER BY p.trace_id DESC, fee_difference DESC
)
SELECT *
FROM final_data
ORDER BY fee_difference DESC;  
