# Notion data-source schema migration snapshot — 작업계획 · Master

- Source data source: collection://3c01b237-eb1c-806c-9bbb-000b7404f739
- Source URL: https://app.notion.com/p/3c01b237eb1c809b9c69f3cf816cb5a9?pvs=204
- Fetched: 2026-08-28 KST
- Authority: structural archive only. The replacement repository owner is mapped in `../MIGRATION_MANIFEST.md`.

---

<data-source url="{{collection://3c01b237-eb1c-806c-9bbb-000b7404f739}}">
The title of this Data Source is: 작업계획 · Master

Here is the database's configurable state:
Properties with `readOnly: true` are synced or system-managed. Do not try to update their values with page update tools.
<data-source-state>
{"default_page_template":"https://app.notion.com/p/3c01b237eb1c8004bd38df50b19f776f","icon":"/icons/iterate_blue.svg","name":"작업계획 · Master","schema":{"Last Edited":{"description":"","name":"Last Edited","type":"last_edited_time"},"Last Synced":{"description":"","name":"Last Synced","querySqlColumns":{"columns":[{"name":"date:Last Synced:start","sqlType":"TEXT"},{"name":"date:Last Synced:end","sqlType":"TEXT"},{"name":"date:Last Synced:is_datetime","sqlType":"INTEGER"}],"usage":"For connections.notion.querySql. Main schema name not queryable."},"type":"date"},"Project":{"dataSourceUrl":"collection://6dab7243-b9b4-464d-b743-45f4e0f1e855","description":"","name":"Project","type":"relation"},"Revision":{"description":"","name":"Revision","type":"number"},"Sync State":{"description":"","name":"Sync State","options":[{"color":"green","description":"","name":"SYNCED","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/aHNTPA/NjAyZDQ2Y2QtZjNmMy00NzQ3LWJlODYtYTA3MjY4MGYwZTlh"},{"color":"yellow","description":"","name":"PROPOSED_NOTION_CHANGE","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/aHNTPA/Y2EwYzAxOGItZWMxYy00NjVmLTk2NjEtM2MyNDgyYjY2Yjg5"},{"color":"orange","description":"","name":"REPO_UPDATE_REQUIRED","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/aHNTPA/NDgyZGE2YzYtY2M2NS00ZGEwLThiYmYtNTk1MGZiZTRlZDA5"},{"color":"red","description":"","name":"REVIEW_REQUIRED","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/aHNTPA/NDFmNTc5YjEtNmQyZS00OTI0LTgyZGYtY2Y5ZTI5ZWZlNjQ2"},{"color":"red","description":"","name":"CONFLICT","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/aHNTPA/YjRmMTU4MjQtYWUxOC00NTU2LWEwYjctZWQ4ODkzMjA0Zjkz"}],"type":"select"},"검증 / 증거":{"description":"","name":"검증 / 증거","type":"text"},"담당자":{"description":"프로젝트 책임자는 누구인가요?","name":"담당자","type":"person"},"상태":{"description":"","groups":{"complete":[{"color":"green","description":"","name":"완료","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/ck91Zw/MjE1MDg2N2ItMGE4ZC00YTRlLTkxMzUtODUwZTQ4N2ViYWQ3"}],"current":[],"future":[],"in_progress":[{"color":"blue","description":"","name":"진행 중","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/ck91Zw/NTlhMjYwMzItZDQ0Ny00NGVkLTliMTctN2M5ZGVjNDM2ZmQz"}],"to_do":[{"description":"","name":"시작 전","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/ck91Zw/Mjg4MmJjNGUtZGE5Zi00ZWIyLWE2OTUtYzliNjRhM2M5ODk5"}]},"name":"상태","type":"status"},"시작일":{"date_format":"MM/DD/YYYY","description":"","name":"시작일","querySqlColumns":{"columns":[{"name":"date:시작일:start","sqlType":"TEXT"},{"name":"date:시작일:end","sqlType":"TEXT"},{"name":"date:시작일:is_datetime","sqlType":"INTEGER"}],"usage":"For connections.notion.querySql. Main schema name not queryable."},"type":"date"},"영역":{"description":"","name":"영역","options":[{"color":"blue","description":"","name":"기획","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/WkpcYA/NDZlZTQxMDYtNjZiZC00OWYyLWE4OTAtNjFkYzAwYzhhMzNj"},{"color":"purple","description":"","name":"시스템","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/WkpcYA/OTM5NjQ5YzgtNjhjOS00NTRjLTgwODYtMTgzMTc1ZWYyYmM0"},{"color":"pink","description":"","name":"비주얼","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/WkpcYA/MTRkNTA5MWItNDQ4NC00ZmQzLTgxNGItZmIwMDZiMWJlNjc4"},{"color":"green","description":"","name":"에셋","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/WkpcYA/MmRiNDYwYjMtMjhiZC00YzIyLWJkMjctNmJlYWFmYWRiOWZl"},{"color":"orange","description":"","name":"구현","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/WkpcYA/MjcwOGVmMDEtNWM0Ny00ODI4LThhMzAtMTI3OTlkNjMxZmEx"},{"color":"yellow","description":"","name":"QA","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/WkpcYA/ZmIwNjQyOGQtZGFkMS00ZWI4LWEwMTQtMmM0YTJkMDA0ZTQ0"},{"color":"gray","description":"","name":"운영","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/WkpcYA/YWYwYzZlMWItMjlmYi00MTc4LTk3MzktODA4Yjc3NzlmYzg5"}],"type":"select"},"완료 기준":{"description":"","name":"완료 기준","type":"text"},"우선순위":{"description":"","name":"우선순위","options":[{"color":"red","description":"","name":"높음","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/WHxRcg/MzFjODgzYTctMzNmOC00NzBlLTkxNzYtODA0MGE0MDEwNmE0"},{"color":"yellow","description":"","name":"보통","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/WHxRcg/NTY5Mzk2ODMtODY1MC00ZDk2LTkxZTEtMGE5ZDFkMWY0YTEz"},{"color":"green","description":"","name":"낮음","url":"collectionPropertyOption://3c01b237-eb1c-806c-9bbb-000b7404f739/WHxRcg/ZjE2YzY2YTctNjRkOS00ZjFhLThlYWItYTk2NWQ4NmMwMWU2"}],"type":"select"},"작업":{"description":"","name":"작업","type":"title"},"작업 ID":{"description":"","name":"작업 ID","type":"auto_increment_id"},"종료일":{"date_format":"MM/DD/YYYY","description":"","name":"종료일","querySqlColumns":{"columns":[{"name":"date:종료일:start","sqlType":"TEXT"},{"name":"date:종료일:end","sqlType":"TEXT"},{"name":"date:종료일:is_datetime","sqlType":"INTEGER"}],"usage":"For connections.notion.querySql. Main schema name not queryable."},"type":"date"},"파일 첨부":{"description":"","name":"파일 첨부","type":"file"}},"url":"collection://3c01b237-eb1c-806c-9bbb-000b7404f739"}
</data-source-state>

Here is the SQLite table definition for this data source.
<sqlite-table>
CREATE TABLE IF NOT EXISTS "collection://3c01b237-eb1c-806c-9bbb-000b7404f739" (
	url TEXT UNIQUE,
	createdTime TEXT, -- ISO-8601 datetime string, automatically set. This is the canonical time for when the page was created.
	"검증 / 증거" TEXT,
	"date:시작일:start" TEXT, -- ISO-8601 date or datetime string. Use the expanded property (date:<column_name>:start) to set this value.
	"date:시작일:end" TEXT, -- ISO-8601 date or datetime string, can be empty. Must be NULL if the date is a single date, and must be present if the date is a range. Use the expanded property (date:<column_name>:end) to set this value.
	"date:시작일:is_datetime" INTEGER, -- 1 if the date is a datetime, 0 if it is a date, NULL defaults to 0. Use the expanded property (date:<column_name>:is_datetime) to set this value.
	"담당자" TEXT, -- JSON array of zero or more user IDs
	"Revision" FLOAT,
	"Project" TEXT, -- JSON array of page URLs relating to {{collection://6dab7243-b9b4-464d-b743-45f4e0f1e855}} data source, you must "view" {{collection://6dab7243-b9b4-464d-b743-45f4e0f1e855}} to query this column
	"파일 첨부" TEXT, -- JSON array of zero or more file IDs, Notion Folder URLs, or <folder> tags copied from fetch output. Folders are stored as native Folder references.
	"우선순위" TEXT, -- one of ["높음", "보통", "낮음"]
	"영역" TEXT, -- one of ["기획", "시스템", "비주얼", "에셋", "구현", "QA", "운영"]
	"완료 기준" TEXT,
	"Last Edited" TEXT NOT NULL, -- ISO-8601 datetime string, automatically set. This is the canonical time for when the page was last edited.
	"date:Last Synced:start" TEXT, -- ISO-8601 date or datetime string. Use the expanded property (date:<column_name>:start) to set this value.
	"date:Last Synced:end" TEXT, -- ISO-8601 date or datetime string, can be empty. Must be NULL if the date is a single date, and must be present if the date is a range. Use the expanded property (date:<column_name>:end) to set this value.
	"date:Last Synced:is_datetime" INTEGER, -- 1 if the date is a datetime, 0 if it is a date, NULL defaults to 0. Use the expanded property (date:<column_name>:is_datetime) to set this value.
	"작업 ID" INTEGER,
	"Sync State" TEXT, -- one of ["SYNCED", "PROPOSED_NOTION_CHANGE", "REPO_UPDATE_REQUIRED", "REVIEW_REQUIRED", "CONFLICT"]
	"date:종료일:start" TEXT, -- ISO-8601 date or datetime string. Use the expanded property (date:<column_name>:start) to set this value.
	"date:종료일:end" TEXT, -- ISO-8601 date or datetime string, can be empty. Must be NULL if the date is a single date, and must be present if the date is a range. Use the expanded property (date:<column_name>:end) to set this value.
	"date:종료일:is_datetime" INTEGER, -- 1 if the date is a datetime, 0 if it is a date, NULL defaults to 0. Use the expanded property (date:<column_name>:is_datetime) to set this value.
	"상태" TEXT, -- one of ["시작 전", "진행 중", "완료"]
	"작업" TEXT
)
</sqlite-table>
</data-source>
