DECLARE @x XML = N'
<fields>
    <field name="Id">
        <val>1</val>
    </field>
    <field name="ProductId">
        <val>5</val>
    </field>
    <field name="Product">
        <val>Chassis</val>
    </field>
    <field name="MarketId">
        <val>43</val>
    </field>
    <field name="Market">
        <val>USA</val>
    </field>
</fields>'

SELECT Id =        t.c.value('(field[@name="Id"]/val/text())[1]', 'INT')
     , ProductId = t.c.value('(field[@name="ProductId"]/val/text())[1]', 'INT')
     , Product =   t.c.value('(field[@name="Product"]/val/text())[1]', 'NVARCHAR(4000)')
     , MarketId =  t.c.value('(field[@name="MarketId"]/val/text())[1]', 'INT')
     , Market =    t.c.value('(field[@name="Market"]/val/text())[1]', 'NVARCHAR(4000)')
FROM @X.nodes('/fields') t(c)

SELECT *
FROM (
    SELECT col = t.c.value('@name', 'SYSNAME')
         , val = t.c.value('(val/text())[1]', 'NVARCHAR(4000)')
    FROM @x.nodes('fields/field') t(c)
) t
PIVOT (
    MAX(val)
    FOR col IN (Id, ProductId, Product, MarketId, Market)
) p
GO

------------------------------------------------------

DECLARE @x XML = N'
<event time="2017-02-04 22:00:01.990">
    <data name="wait_type">CXPACKET</data>
    <data name="duration">123</data>
    <data name="signal_duration">123</data>
    <data name="info">App</data>
</event>
<event time="2017-02-04 22:02:16.020">
    <data name="wait_type">WRITELOG</data>
    <data name="duration">3</data>
    <data name="signal_duration">0</data>
</event>
<event time="2017-02-04 22:02:58.970">
    <data name="wait_type">WRITELOG</data>
    <data name="duration">1</data>
    <data name="signal_duration">0</data>
</event>
'

SELECT wait_type
     , duration = SUM(duration)
     , signal_duration = SUM(signal_duration)
     , waiting_tasks_count = COUNT_BIG(*)
FROM (
    SELECT wait_type = c.value('(data[@name="wait_type"]/text())[1]', 'NVARCHAR(4000)')
         , duration = c.value('(data[@name="duration"]/text())[1]', 'BIGINT')
         , signal_duration = c.value('(data[@name="signal_duration"]/text())[1]', 'BIGINT')
    FROM @x.nodes('event') t(c)
) t
GROUP BY wait_type

SELECT wait_type
     , duration = SUM(duration)
     , signal_duration = SUM(signal_duration)
     , waiting_tasks_count = COUNT_BIG(*)
FROM (
    SELECT wait_type = MAX(CASE WHEN n = 'wait_type' THEN x.value('(data/text())[1]', 'NVARCHAR(4000)') END)
         , duration = MAX(CASE WHEN n = 'duration' THEN x.value('(data/text())[1]', 'BIGINT') END)
         , signal_duration = MAX(CASE WHEN n = 'signal_duration' THEN x.value('(data/text())[1]', 'BIGINT') END)
    FROM (
        SELECT n = c.value('@name', 'SYSNAME')
             , x = c.query('.')
             , rn = ROW_NUMBER() OVER (ORDER BY 1/0) - ISNULL(NULLIF(ROW_NUMBER() OVER (ORDER BY 1/0) % 3, 0), 3)
        FROM @x.nodes('event/data[(contains("wait_type,duration,signal_duration", @name))]') t(c)
    ) t
    GROUP BY rn
) t
GROUP BY wait_type