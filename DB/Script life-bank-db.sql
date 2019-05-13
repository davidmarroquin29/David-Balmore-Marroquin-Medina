-- Database: life-bank-db

-- DROP DATABASE "life-bank-db";

CREATE DATABASE "life-bank-db"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_El Salvador.1252'
    LC_CTYPE = 'Spanish_El Salvador.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE "life-bank-db"
    IS 'Base de datos para LifeBank';
	
-- SCHEMA: lb_user

-- DROP SCHEMA lb_user ;

CREATE SCHEMA lb_user
    AUTHORIZATION postgres;
	
	
-- Table: lb_user.signin

-- DROP TABLE lb_user.signin;

CREATE TABLE lb_user.signin
(
    signin_id integer NOT NULL DEFAULT nextval('lb_user.signin_signin_id_seq'::regclass) ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    signin_userid integer,
    signin_count integer,
    CONSTRAINT signin_pkey PRIMARY KEY (signin_id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE lb_user.signin
    OWNER to postgres;
	
	
	
-- Table: lb_user.users

-- DROP TABLE lb_user.users;

CREATE TABLE lb_user.users
(
    user_id integer NOT NULL,
    user_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    user_password character varying(100) COLLATE pg_catalog."default" NOT NULL,
    user_firstname character varying(50) COLLATE pg_catalog."default" NOT NULL,
    user_lastname character varying(50) COLLATE pg_catalog."default" NOT NULL,
    user_birthday timestamp without time zone,
    user_enrolldate timestamp without time zone,
    user_status character varying(1) COLLATE pg_catalog."default" DEFAULT 'A'::character varying,
    CONSTRAINT users_pkey PRIMARY KEY (user_id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE lb_user.users
    OWNER to postgres;

-- Trigger: ins_usr_signin

-- DROP TRIGGER ins_usr_signin ON lb_user.users;

CREATE TRIGGER ins_usr_signin
    AFTER INSERT
    ON lb_user.users
    FOR EACH ROW
    EXECUTE PROCEDURE lb_user.usr_insert();
	
	
	
	
-- Table: lb_user.products

-- DROP TABLE lb_user.products;

CREATE TABLE lb_user.products
(
    product_id integer NOT NULL,
    product_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    product_description character varying(100) COLLATE pg_catalog."default" NOT NULL,
    product_status character varying(1) COLLATE pg_catalog."default" DEFAULT 'A'::character varying,
    CONSTRAINT products_pkey PRIMARY KEY (product_id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE lb_user.products
    OWNER to postgres;
	
	
	
	
	
-- Table: lb_user.productsxuser

-- DROP TABLE lb_user.productsxuser;

CREATE TABLE lb_user.productsxuser
(
    pxu_id integer NOT NULL,
    pxu_prodid integer,
    pxu_usrid integer,
    pxu_name character varying(50) COLLATE pg_catalog."default",
    pxu_description character varying(100) COLLATE pg_catalog."default",
    product_status character varying(1) COLLATE pg_catalog."default" DEFAULT 'A'::character varying,
    CONSTRAINT productsxuser_pkey PRIMARY KEY (pxu_id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE lb_user.productsxuser
    OWNER to postgres;
	
	
	
	
	
	
	
	
-- FUNCTION: lb_user.get_user_id_login(character varying, character varying)

-- DROP FUNCTION lb_user.get_user_id_login(character varying, character varying);

CREATE OR REPLACE FUNCTION lb_user.get_user_id_login(
	puser_name character varying,
	puser_pass character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
  v_returnCode VARCHAR;
  v_userId integer;
  v_lastTry integer;
BEGIN
    SELECT u.user_id into v_userId from lb_user.users u where u.user_name = pUser_name and u.user_password = pUser_pass and u.user_status = 'A';
	
	v_returnCode := '000';
	
    IF v_userId IS NULL THEN
		
		v_returnCode := '001';
	
        SELECT max(s.signin_count) into v_lastTry from lb_user.signin s where s.signin_userid = v_userId;
		
		if v_lastTry >= 4 then
			v_returnCode := '002';
		end if;
		
		--begin
		--	PERFORM dblink_connect('dblink_trans','dbname=life-bank-db port=5433 user=postgres');
        --	PERFORM dblink('dblink_trans','update lb_user.signin set signin_count = ' || v_lastTry || ' +1 where signin_userid = ' || v_userId);
        --	PERFORM dblink('dblink_trans','COMMIT;');
        --	PERFORM dblink_disconnect('dblink_trans'); 
			--update lb_user.signin set signin_count = v_lastTry +1 where signin_userid = v_userId;
			--commit;
		--end;
		
    END IF;

    RETURN v_returnCode;

END;
$BODY$;

ALTER FUNCTION lb_user.get_user_id_login(character varying, character varying)
    OWNER TO postgres;
