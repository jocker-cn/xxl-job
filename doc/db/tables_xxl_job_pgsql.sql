-- 创建数据库（PostgreSQL 不支持 `IF NOT EXISTS`，可以手动检查并创建）
-- PostgreSQL 默认字符集是 UTF8，所以不需要设置字符集
CREATE DATABASE xxl_job ENCODING 'UTF8';

CREATE TABLE public.xxl_job_info
(
    id                        SERIAL PRIMARY KEY,                         -- PostgreSQL 使用 SERIAL 自动递增 ID
    job_group                 INT          NOT NULL,                      -- INT 类型
    job_desc                  VARCHAR(255) NOT NULL,
    add_time                  TIMESTAMP             DEFAULT NULL,         -- 使用 TIMESTAMP 替代 DATETIME
    update_time               TIMESTAMP             DEFAULT NULL,
    author                    VARCHAR(64)           DEFAULT NULL,         -- 可选字段
    alarm_email               VARCHAR(255)          DEFAULT NULL,         -- 可选字段
    schedule_type             VARCHAR(50)  NOT NULL DEFAULT 'NONE',       -- 默认值
    schedule_conf             VARCHAR(128)          DEFAULT NULL,
    misfire_strategy          VARCHAR(50)  NOT NULL DEFAULT 'DO_NOTHING', -- 默认值
    executor_route_strategy   VARCHAR(50)           DEFAULT NULL,
    executor_handler          VARCHAR(255)          DEFAULT NULL,
    executor_param            VARCHAR(512)          DEFAULT NULL,
    executor_block_strategy   VARCHAR(50)           DEFAULT NULL,
    executor_timeout          INT          NOT NULL DEFAULT 0,            -- 默认值
    executor_fail_retry_count INT          NOT NULL DEFAULT 0,
    glue_type                 VARCHAR(50)  NOT NULL,                      -- GLUE 类型字段
    glue_source               TEXT,                                       -- 添加字段: glue_source (mediumtext 转为 TEXT)
    glue_remark               VARCHAR(128)          DEFAULT NULL,         -- 添加字段: glue_remark
    glue_updatetime           TIMESTAMP             DEFAULT NULL,         -- 添加字段: glue_updatetime
    child_jobid               varchar(255)          DEFAULT NULL,         -- 添加字段: child_jobid
    trigger_status            INT          NOT NULL DEFAULT '0',          -- 添加字段: trigger_status
    trigger_last_time         bigint       NOT NULL DEFAULT 0,            -- 添加字段: trigger_last_time
    trigger_next_time         bigint       NOT NULL DEFAULT 0             -- 添加字段: trigger_next_time
);


-- 创建其他表格（按照相同方式修改）

CREATE TABLE public.xxl_job_log
(
    id                        BIGSERIAL PRIMARY KEY,          -- 使用 BIGSERIAL 来替代 BIGINT AUTO_INCREMENT
    job_group                 INT      NOT NULL,              -- INT 类型
    job_id                    INT      NOT NULL,              -- 任务主键 ID
    executor_address          VARCHAR(255)      DEFAULT NULL, -- 执行器地址
    executor_handler          VARCHAR(255)      DEFAULT NULL, -- 执行器任务 handler
    executor_param            VARCHAR(512)      DEFAULT NULL, -- 执行器任务参数
    executor_sharding_param   VARCHAR(20)       DEFAULT NULL, -- 执行器任务分片参数
    executor_fail_retry_count INT      NOT NULL DEFAULT 0,    -- 失败重试次数
    trigger_time              TIMESTAMP         DEFAULT NULL, -- 调度时间
    trigger_code              INT      NOT NULL,              -- 调度结果
    trigger_msg               TEXT,                           -- 调度日志
    handle_time               TIMESTAMP         DEFAULT NULL, -- 执行时间
    handle_code               INT      NOT NULL,              -- 执行状态
    handle_msg                TEXT,                           -- 执行日志
    alarm_status              SMALLINT NOT NULL DEFAULT 0     -- 告警状态：0-默认、1-无需告警、2-告警成功、3-告警失败
);

CREATE INDEX idx_trigger_time_idx ON xxl_job_log (trigger_time);
CREATE INDEX idx_handle_code_idx ON xxl_job_log (handle_code);
CREATE INDEX idx_jobid_jobgroup_idx ON xxl_job_log (job_id, job_group);
CREATE INDEX idx_job_id_idx ON xxl_job_log (job_id);


-- 创建表: xxl_job_log_report
CREATE TABLE public.xxl_job_log_report
(
    id            SERIAL PRIMARY KEY,        -- 使用 SERIAL 来替代 INT AUTO_INCREMENT
    trigger_day   TIMESTAMP    DEFAULT NULL, -- 调度时间（使用 TIMESTAMP 替代 DATETIME）
    running_count INT NOT NULL DEFAULT 0,    -- 运行中日志数量
    suc_count     INT NOT NULL DEFAULT 0,    -- 执行成功日志数量
    fail_count    INT NOT NULL DEFAULT 0,    -- 执行失败日志数量
    update_time   TIMESTAMP    DEFAULT NULL  -- 更新时间（使用 TIMESTAMP 替代 DATETIME）
);
-- 创建唯一索引
CREATE UNIQUE INDEX idx_trigger_day ON xxl_job_log_report (trigger_day);

-- 创建表: xxl_job_logglue
CREATE TABLE public.xxl_job_logglue
(
    id          SERIAL PRIMARY KEY,       -- 使用 SERIAL 来替代 INT AUTO_INCREMENT
    job_id      INT          NOT NULL,    -- 任务主键 ID
    glue_type   VARCHAR(50) DEFAULT NULL, -- GLUE 类型
    glue_source TEXT,                     -- GLUE 源代码（使用 TEXT 替代 mediumtext）
    glue_remark VARCHAR(128) NOT NULL,    -- GLUE 备注
    add_time    TIMESTAMP   DEFAULT NULL, -- 添加时间（使用 TIMESTAMP 替代 DATETIME）
    update_time TIMESTAMP   DEFAULT NULL  -- 更新时间（使用 TIMESTAMP 替代 DATETIME）
);

-- 创建表: xxl_job_registry
CREATE TABLE public.xxl_job_registry
(
    id             SERIAL PRIMARY KEY,    -- 使用 SERIAL 来替代 INT AUTO_INCREMENT
    registry_group VARCHAR(50)  NOT NULL, -- 注册组
    registry_key   VARCHAR(255) NOT NULL, -- 注册键
    registry_value VARCHAR(255) NOT NULL, -- 注册值
    update_time    TIMESTAMP DEFAULT NULL -- 更新时间（使用 TIMESTAMP 替代 DATETIME）

);
-- 创建唯一索引
CREATE UNIQUE INDEX i_g_k_v ON xxl_job_registry (registry_group, registry_key, registry_value);

-- 创建表: xxl_job_group
CREATE TABLE public.xxl_job_group
(
    id           SERIAL PRIMARY KEY,               -- 使用 SERIAL 来替代 INT AUTO_INCREMENT
    app_name     VARCHAR(64) NOT NULL,             -- 执行器 AppName
    title        VARCHAR(12) NOT NULL,             -- 执行器名称
    address_type SMALLINT    NOT NULL DEFAULT 0,   -- 执行器地址类型（使用 SMALLINT 替代 TINYINT）
    address_list TEXT,                             -- 执行器地址列表（多地址逗号分隔）
    update_time  TIMESTAMP            DEFAULT NULL -- 更新时间（使用 TIMESTAMP 替代 DATETIME）
);

-- 创建表: xxl_job_user
CREATE TABLE public.xxl_job_user
(
    id         SERIAL PRIMARY KEY,          -- 使用 SERIAL 来替代 INT AUTO_INCREMENT
    username   VARCHAR(50) UNIQUE NOT NULL, -- 账号
    password   VARCHAR(50)        NOT NULL, -- 密码
    role       SMALLINT           NOT NULL, -- 角色（使用 SMALLINT 替代 TINYINT）
    permission VARCHAR(255) DEFAULT NULL    -- 权限（执行器ID列表，多个逗号分割）
);


-- 创建表: xxl_job_lock
CREATE TABLE public.xxl_job_lock
(
    lock_name VARCHAR(50) NOT NULL, -- 锁名称
    PRIMARY KEY (lock_name)         -- 主键约束
);


-- 插入数据到 xxl_job_group
INSERT INTO public.xxl_job_group (app_name, title, address_type, address_list, update_time)
VALUES ('xxl-job-executor-sample', '示例执行器', 0, NULL, '2018-11-03 22:21:31');

-- 插入数据到 xxl_job_info
INSERT INTO public.xxl_job_info (job_group, job_desc, add_time, update_time, author, alarm_email,
                                 schedule_type, schedule_conf, misfire_strategy, executor_route_strategy,
                                 executor_handler, executor_param, executor_block_strategy, executor_timeout,
                                 executor_fail_retry_count, glue_type, glue_source, glue_remark, glue_updatetime,
                                 child_jobid)
VALUES (1, '测试任务1', '2018-11-03 22:21:31', '2018-11-03 22:21:31', 'XXL', '', 'CRON', '0 0 0 * * ? *',
        'DO_NOTHING', 'FIRST', 'demoJobHandler', '', 'SERIAL_EXECUTION', 0, 0, 'BEAN', '', 'GLUE代码初始化',
        '2018-11-03 22:21:31', NULL);

-- 插入数据到 xxl_job_user
INSERT INTO public.xxl_job_user (username, password, role, permission)
VALUES ('admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL);

-- 插入数据到 xxl_job_lock
INSERT INTO public.xxl_job_lock (lock_name)
VALUES ('schedule_lock');