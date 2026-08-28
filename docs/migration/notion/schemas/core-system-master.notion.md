# Notion data-source schema migration snapshot — CORE SYSTEM · Master

- Source data source: collection://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79
- Source URL: https://app.notion.com/p/5b832abb8b904f9b9a620b8ab8f90c2d?pvs=204
- Fetched: 2026-08-28 KST
- Authority: structural archive only. The replacement repository owner is mapped in `../MIGRATION_MANIFEST.md`.

---

<data-source url="{{collection://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79}}">
The title of this Data Source is: CORE SYSTEM · Master

Here is the database's configurable state:
Properties with `readOnly: true` are synced or system-managed. Do not try to update their values with page update tools.
<data-source-state>
{"name":"CORE SYSTEM · Master","schema":{"Category":{"description":"","name":"Category","type":"text"},"Children":{"dataSourceUrl":"collection://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79","description":"","name":"Children","propertyUrl":"collectionProperty://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/YnZvfg","type":"relation"},"Dependencies":{"description":"","name":"Dependencies","type":"text"},"Last Edited":{"description":"","name":"Last Edited","type":"last_edited_time"},"Last Synced":{"description":"","name":"Last Synced","querySqlColumns":{"columns":[{"name":"date:Last Synced:start","sqlType":"TEXT"},{"name":"date:Last Synced:end","sqlType":"TEXT"},{"name":"date:Last Synced:is_datetime","sqlType":"INTEGER"}],"usage":"For connections.notion.querySql. Main schema name not queryable."},"type":"date"},"Name":{"description":"","name":"Name","type":"title"},"Parent":{"dataSourceUrl":"collection://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79","description":"","name":"Parent","propertyUrl":"collectionProperty://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/ej9iaQ","type":"relation"},"Player Meaning":{"description":"","name":"Player Meaning","type":"text"},"Project":{"dataSourceUrl":"collection://6dab7243-b9b4-464d-b743-45f4e0f1e855","description":"","name":"Project","type":"relation"},"Record ID":{"description":"","name":"Record ID","type":"auto_increment_id"},"Record Key":{"description":"","name":"Record Key","type":"text"},"Record Type":{"description":"","name":"Record Type","options":[{"color":"blue","description":"","name":"SYSTEM","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/ZDU1MjQ5YTgtYjM2Mi00MjU4LWI3NjEtNzVhMjJkMzcwNjVj"},{"color":"blue","description":"","name":"LOOP","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/YzJjNDhlY2ItN2Q0NC00ODU3LThhZDAtZmZkOWIyNDMyODIz"},{"color":"gray","description":"","name":"RULE","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/MmJhOTEyOGMtYTAwZS00NTI3LThjNzktN2RkM2Q3NmUzYmNk"},{"color":"green","description":"","name":"RESOURCE","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/NzQxNmEzZWQtMGUyMS00NTdiLWE3OGYtMjA1NjExNzFjODYx"},{"color":"purple","description":"","name":"STAT","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/ZTgzMGI4MTktNWRiZi00YWM4LTg4ZjktM2RkNWEzNmQ1ZWNm"},{"color":"orange","description":"","name":"NODE","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/N2MwNzBiYzUtMzRmZC00NzY1LWI2MmItMmZkODhhMTg0YWQx"},{"color":"brown","description":"","name":"BUILDING","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/YzA0YWYxNzMtNzA4NS00ODBmLWE5ZDQtYjZhMjk4NWIxYmNl"},{"color":"red","description":"","name":"UNIT","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/ZjIzZWNlNzQtNTc2My00YzEwLTlmMGEtODY1OWMyYmRiMDNi"},{"color":"purple","description":"","name":"MARTIAL_MANUAL","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/NDU3ZWY2YmMtNmNkOC00ZTcwLWI0ZDktNTI0MzU4ODNlMWMz"},{"color":"pink","description":"","name":"SKILL","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/NWZlMWMwMjYtOTliNS00ZGNmLTgzNjUtNGE4ZGEyZmIzMmI5"},{"color":"yellow","description":"","name":"EFFECT","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/ZjVmOTU5MDMtYTNiOC00YzdkLWIyYjAtMDU1Zjc2OTkzMTg5"},{"color":"orange","description":"","name":"ITEM","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/YjVmODdiMjctMzRkZC00YjA5LWI1ZDMtZTBlNGI2ZjcwMjUy"},{"color":"yellow","description":"","name":"EVENT","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/NjU4ZmM3OWMtMmVjNy00NmMzLWE4NGQtZDA1YWNmMjJhYzk2"},{"color":"green","description":"","name":"COLLECTION","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/MjQ3NGE4NmUtMzNmMC00ZDUxLWE0MTUtMTk3ZjMzM2YwNWQ0"},{"color":"gray","description":"","name":"STATE","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Z3xwYg/MTEyOWE5ZmUtZmIxMi00N2I3LTg2ZjAtMDg5NzY0YzA2YzAz"}],"type":"select"},"Revision":{"description":"","name":"Revision","type":"number"},"Rule / Effect":{"description":"","name":"Rule / Effect","type":"text"},"Source Path":{"description":"","name":"Source Path","type":"text"},"Source SHA":{"description":"","name":"Source SHA","type":"text"},"Status":{"description":"","name":"Status","options":[{"color":"green","description":"","name":"CONFIRMED","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/R2RHTQ/ZjkyMDdiOTUtNjMzYi00NGY5LTkyY2ItYzVlMTgwMjQ2MzJi"},{"color":"yellow","description":"","name":"PROVISIONAL","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/R2RHTQ/MDkyN2U2MGQtYTEyNy00NDAzLThmMWItZjM5OWU0MjdmYTRj"},{"color":"gray","description":"","name":"DEFERRED","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/R2RHTQ/YWUyZmRiMDQtN2M5YS00MjA3LWEyMzEtYWY2NGE3ZTQzZDAz"},{"color":"red","description":"","name":"REJECTED","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/R2RHTQ/MmRiZGI4MzItN2VlOS00NzM1LThkNzktOGNlNDEzYjU4MTI3"}],"type":"select"},"Summary":{"description":"","name":"Summary","type":"text"},"Sync State":{"description":"","name":"Sync State","options":[{"color":"green","description":"","name":"SYNCED","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Xz5Ybw/Mjk0ZjU3OTctNThhMi00NWQ4LTg4N2MtMDI0NDFiMDRkYjM2"},{"color":"yellow","description":"","name":"PROPOSED_NOTION_CHANGE","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Xz5Ybw/NTg4OGIxOTQtODk1YS00OWZiLTg2Y2MtY2YyYzMzMTYxZWYw"},{"color":"orange","description":"","name":"REPO_UPDATE_REQUIRED","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Xz5Ybw/MzI5NTI4MDItMmFmNS00MWM3LWFkNmUtYjJkYjJlZmRjNWRi"},{"color":"red","description":"","name":"REVIEW_REQUIRED","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Xz5Ybw/OWQ2OTliYTItYTNlOC00MzZmLThlMjQtYjhkMGNhZjVjZTk2"},{"color":"red","description":"","name":"CONFLICT","url":"collectionPropertyOption://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79/Xz5Ybw/ZTE0YzdlNmMtNzZhZi00OGY0LWJmMTEtMTE4ODBkYzM1NjI2"}],"type":"select"},"Values":{"description":"","name":"Values","type":"text"}},"url":"collection://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79"}
</data-source-state>

Here is the SQLite table definition for this data source.
<sqlite-table>
CREATE TABLE IF NOT EXISTS "collection://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79" (
	url TEXT UNIQUE,
	createdTime TEXT, -- ISO-8601 datetime string, automatically set. This is the canonical time for when the page was created.
	"Record ID" INTEGER,
	"Summary" TEXT,
	"Project" TEXT, -- JSON array of page URLs relating to {{collection://6dab7243-b9b4-464d-b743-45f4e0f1e855}} data source, you must "view" {{collection://6dab7243-b9b4-464d-b743-45f4e0f1e855}} to query this column
	"Revision" FLOAT,
	"Status" TEXT, -- one of ["CONFIRMED", "PROVISIONAL", "DEFERRED", "REJECTED"]
	"Player Meaning" TEXT,
	"Sync State" TEXT, -- one of ["SYNCED", "PROPOSED_NOTION_CHANGE", "REPO_UPDATE_REQUIRED", "REVIEW_REQUIRED", "CONFLICT"]
	"Values" TEXT,
	"Source Path" TEXT,
	"Parent" TEXT, -- JSON array of page URLs relating to {{collection://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79}} data source, you must "view" {{collection://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79}} to query this column
	"Category" TEXT,
	"Rule / Effect" TEXT,
	"Record Type" TEXT, -- one of ["SYSTEM", "LOOP", "RULE", "RESOURCE", "STAT", "NODE", "BUILDING", "UNIT", "MARTIAL_MANUAL", "SKILL", "EFFECT", "ITEM", "EVENT", "COLLECTION", "STATE"]
	"date:Last Synced:start" TEXT, -- ISO-8601 date or datetime string. Use the expanded property (date:<column_name>:start) to set this value.
	"date:Last Synced:end" TEXT, -- ISO-8601 date or datetime string, can be empty. Must be NULL if the date is a single date, and must be present if the date is a range. Use the expanded property (date:<column_name>:end) to set this value.
	"date:Last Synced:is_datetime" INTEGER, -- 1 if the date is a datetime, 0 if it is a date, NULL defaults to 0. Use the expanded property (date:<column_name>:is_datetime) to set this value.
	"Record Key" TEXT,
	"Dependencies" TEXT,
	"Last Edited" TEXT NOT NULL, -- ISO-8601 datetime string, automatically set. This is the canonical time for when the page was last edited.
	"Children" TEXT, -- JSON array of page URLs relating to {{collection://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79}} data source, you must "view" {{collection://b0b4e81d-2400-43f2-b02b-88f1d3c1cb79}} to query this column
	"Source SHA" TEXT,
	"Name" TEXT
)
</sqlite-table>
</data-source>
