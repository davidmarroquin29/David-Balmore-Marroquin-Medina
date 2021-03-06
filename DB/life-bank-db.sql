PGDMP                         w            life-bank-db    10.7    10.7 "    d           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            e           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            f           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            g           1262    16393    life-bank-db    DATABASE     �   CREATE DATABASE "life-bank-db" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_El Salvador.1252' LC_CTYPE = 'Spanish_El Salvador.1252';
    DROP DATABASE "life-bank-db";
             postgres    false            h           0    0    DATABASE "life-bank-db"    COMMENT     E   COMMENT ON DATABASE "life-bank-db" IS 'Base de datos para LifeBank';
                  postgres    false    2919                        2615    16394    lb_user    SCHEMA        CREATE SCHEMA lb_user;
    DROP SCHEMA lb_user;
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            i           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    5                        3079    12924    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            j           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1                        3079    16453    dblink 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA lb_user;
    DROP EXTENSION dblink;
                  false    7            k           0    0    EXTENSION dblink    COMMENT     _   COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';
                       false    3                        3079    16499    pldbgapi 	   EXTENSION     =   CREATE EXTENSION IF NOT EXISTS pldbgapi WITH SCHEMA lb_user;
    DROP EXTENSION pldbgapi;
                  false    7            l           0    0    EXTENSION pldbgapi    COMMENT     Y   COMMENT ON EXTENSION pldbgapi IS 'server-side support for debugging PL/pgSQL functions';
                       false    2                       1255    16452 7   get_user_id_login(character varying, character varying)    FUNCTION     �  CREATE FUNCTION lb_user.get_user_id_login(puser_name character varying, puser_pass character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
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
$$;
 e   DROP FUNCTION lb_user.get_user_id_login(puser_name character varying, puser_pass character varying);
       lb_user       postgres    false    1    7            �            1255    16450    usr_insert()    FUNCTION     �   CREATE FUNCTION lb_user.usr_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
         INSERT INTO lb_user.signin(signin_userid,signin_count)
         VALUES(NEW.user_id,0);
 
    RETURN NEW;
END;
$$;
 $   DROP FUNCTION lb_user.usr_insert();
       lb_user       postgres    false    1    7            �            1255    16434    usr_insert()    FUNCTION     �   CREATE FUNCTION public.usr_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
         INSERT INTO lb_user.signin(signin_id,signin_userid,signin_count)
         VALUES(NEW.user_id,NEW.user_id,0);
 
    RETURN NEW;
END;
$$;
 #   DROP FUNCTION public.usr_insert();
       public       postgres    false    5    1            �            1259    24585    products    TABLE     �   CREATE TABLE lb_user.products (
    product_id integer NOT NULL,
    product_name character varying(20) NOT NULL,
    product_description character varying(100) NOT NULL,
    product_status character varying(1) DEFAULT 'A'::character varying
);
    DROP TABLE lb_user.products;
       lb_user         postgres    false    7            �            1259    24591    productsxuser    TABLE       CREATE TABLE lb_user.productsxuser (
    pxu_id integer NOT NULL,
    pxu_prodid integer,
    pxu_usrid integer,
    pxu_name character varying(50),
    pxu_description character varying(100),
    product_status character varying(1) DEFAULT 'A'::character varying
);
 "   DROP TABLE lb_user.productsxuser;
       lb_user         postgres    false    7            �            1259    16438    signin    TABLE     u   CREATE TABLE lb_user.signin (
    signin_id integer NOT NULL,
    signin_userid integer,
    signin_count integer
);
    DROP TABLE lb_user.signin;
       lb_user         postgres    false    7            �            1259    16436    signin_signin_id_seq    SEQUENCE     �   CREATE SEQUENCE lb_user.signin_signin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE lb_user.signin_signin_id_seq;
       lb_user       postgres    false    200    7            m           0    0    signin_signin_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE lb_user.signin_signin_id_seq OWNED BY lb_user.signin.signin_id;
            lb_user       postgres    false    199            �            1259    16444    users    TABLE     �  CREATE TABLE lb_user.users (
    user_id integer NOT NULL,
    user_name character varying(20) NOT NULL,
    user_password character varying(100) NOT NULL,
    user_firstname character varying(50) NOT NULL,
    user_lastname character varying(50) NOT NULL,
    user_birthday timestamp without time zone,
    user_enrolldate timestamp without time zone,
    user_status character varying(1) DEFAULT 'A'::character varying
);
    DROP TABLE lb_user.users;
       lb_user         postgres    false    7            �
           2604    16441    signin signin_id    DEFAULT     v   ALTER TABLE ONLY lb_user.signin ALTER COLUMN signin_id SET DEFAULT nextval('lb_user.signin_signin_id_seq'::regclass);
 @   ALTER TABLE lb_user.signin ALTER COLUMN signin_id DROP DEFAULT;
       lb_user       postgres    false    199    200    200            `          0    24585    products 
   TABLE DATA               b   COPY lb_user.products (product_id, product_name, product_description, product_status) FROM stdin;
    lb_user       postgres    false    208   �(       a          0    24591    productsxuser 
   TABLE DATA               r   COPY lb_user.productsxuser (pxu_id, pxu_prodid, pxu_usrid, pxu_name, pxu_description, product_status) FROM stdin;
    lb_user       postgres    false    209   �(       ^          0    16438    signin 
   TABLE DATA               I   COPY lb_user.signin (signin_id, signin_userid, signin_count) FROM stdin;
    lb_user       postgres    false    200   �)       _          0    16444    users 
   TABLE DATA               �   COPY lb_user.users (user_id, user_name, user_password, user_firstname, user_lastname, user_birthday, user_enrolldate, user_status) FROM stdin;
    lb_user       postgres    false    201   �)       n           0    0    signin_signin_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('lb_user.signin_signin_id_seq', 3, true);
            lb_user       postgres    false    199            �
           2606    24590    products products_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY lb_user.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);
 A   ALTER TABLE ONLY lb_user.products DROP CONSTRAINT products_pkey;
       lb_user         postgres    false    208            �
           2606    24596     productsxuser productsxuser_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY lb_user.productsxuser
    ADD CONSTRAINT productsxuser_pkey PRIMARY KEY (pxu_id);
 K   ALTER TABLE ONLY lb_user.productsxuser DROP CONSTRAINT productsxuser_pkey;
       lb_user         postgres    false    209            �
           2606    16443    signin signin_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY lb_user.signin
    ADD CONSTRAINT signin_pkey PRIMARY KEY (signin_id);
 =   ALTER TABLE ONLY lb_user.signin DROP CONSTRAINT signin_pkey;
       lb_user         postgres    false    200            �
           2606    16449    users users_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY lb_user.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);
 ;   ALTER TABLE ONLY lb_user.users DROP CONSTRAINT users_pkey;
       lb_user         postgres    false    201            �
           2620    16451    users ins_usr_signin    TRIGGER     q   CREATE TRIGGER ins_usr_signin AFTER INSERT ON lb_user.users FOR EACH ROW EXECUTE PROCEDURE lb_user.usr_insert();
 .   DROP TRIGGER ins_usr_signin ON lb_user.users;
       lb_user       postgres    false    201    215            `   <   x�3���O��,-N-R ���8��RS2K��R H|G.c΂Ԣ����8�3F��� `�?      a   �   x����
� ����S����e�u���6F�����5p�ë�88��"?�W|2�U��p�m���іߍ��v��"�R�g�
(w�n����
i����p?�`��#�1�N��,��H�-��o�bZ\pk�:��q̓�_I*.�-�����;�^��1�!#{.�4Z�u�B�����      ^      x�3�4�4�2�4�Ɯ�@2F��� !a�      _   I   x�3�,I-.1�,H,..�/J142��*M��H-J���!G.#�2#eFuFp��`��
�!
��
c���� pO$P     