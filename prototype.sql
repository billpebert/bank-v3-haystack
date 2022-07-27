-- --------------------------------------------------------
-- Host:                         localhost
-- Server version:               5.7.33 - MySQL Community Server (GPL)
-- Server OS:                    Win64
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table prototypeaccounts.accountclass
CREATE TABLE IF NOT EXISTS `accountclass` (
  `Window` int(8) unsigned NOT NULL,
  `AccountClass` varchar(35) DEFAULT NULL,
  `nostro` tinyint(1) unsigned DEFAULT '0',
  `balancesheet` tinyint(1) unsigned DEFAULT '0',
  `asset` tinyint(1) unsigned DEFAULT '0',
  `income` tinyint(1) unsigned DEFAULT '0',
  `matched` tinyint(1) unsigned DEFAULT '0',
  PRIMARY KEY (`Window`),
  UNIQUE KEY `AccountClass-idx` (`AccountClass`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table prototypeaccounts.accountclass: ~0 rows (approximately)
/*!40000 ALTER TABLE `accountclass` DISABLE KEYS */;
INSERT INTO `accountclass` (`Window`, `AccountClass`, `nostro`, `balancesheet`, `asset`, `income`, `matched`) VALUES
	(1, 'AccClass1', 0, 0, 0, 0, 0);
/*!40000 ALTER TABLE `accountclass` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.accounts
CREATE TABLE IF NOT EXISTS `accounts` (
  `AccountID` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `AccountName` varchar(60) COLLATE latin1_bin DEFAULT NULL,
  `AccountFK` int(8) unsigned NOT NULL DEFAULT '1',
  `DefaultSegment` int(8) unsigned DEFAULT NULL,
  `bloomberg` varchar(75) COLLATE latin1_bin DEFAULT NULL,
  `epic` varchar(20) COLLATE latin1_bin DEFAULT NULL,
  `tstampaccounts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `currency` varchar(3) COLLATE latin1_bin DEFAULT '£',
  `Taxcountry` varchar(2) COLLATE latin1_bin DEFAULT 'GB',
  PRIMARY KEY (`AccountID`),
  UNIQUE KEY `AccountNameIndex` (`AccountName`),
  KEY `Foreign` (`AccountFK`),
  KEY `defseg-indx` (`DefaultSegment`),
  CONSTRAINT `FK_accounts_accounttypes` FOREIGN KEY (`AccountFK`) REFERENCES `accounttypes` (`AccountFK`)
) ENGINE=InnoDB AUTO_INCREMENT=3579 DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.accounts: ~0 rows (approximately)
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` (`AccountID`, `AccountName`, `AccountFK`, `DefaultSegment`, `bloomberg`, `epic`, `tstampaccounts`, `currency`, `Taxcountry`) VALUES
	(3578, 'Acc1', 3, NULL, NULL, NULL, '2022-01-02 19:15:30', '£', 'GB');
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;

-- Dumping structure for view prototypeaccounts.accountsjoined
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `accountsjoined` (
	`AccountFK` INT(8) UNSIGNED NOT NULL,
	`accountID` INT(8) UNSIGNED NOT NULL,
	`AccountName` VARCHAR(60) NULL COLLATE 'latin1_bin',
	`DefaultSegment` INT(8) UNSIGNED NULL,
	`bloomberg` VARCHAR(75) NULL COLLATE 'latin1_bin',
	`epic` VARCHAR(20) NULL COLLATE 'latin1_bin',
	`currency` VARCHAR(3) NULL COLLATE 'latin1_bin',
	`taxcountry` VARCHAR(2) NULL COLLATE 'latin1_bin',
	`AccountTypesName` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`window` INT(8) UNSIGNED NOT NULL,
	`accountclass` VARCHAR(35) NULL COLLATE 'latin1_swedish_ci',
	`nostro` TINYINT(1) UNSIGNED NULL,
	`balancesheet` TINYINT(1) UNSIGNED NULL,
	`asset` TINYINT(1) UNSIGNED NULL,
	`income` TINYINT(1) UNSIGNED NULL,
	`matched` TINYINT(1) UNSIGNED NULL,
	`DefaultSegName` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`DefaultSegGrpID` INT(8) UNSIGNED NULL,
	`DefaultSegGrp` VARCHAR(35) NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;

-- Dumping structure for table prototypeaccounts.accounttypes
CREATE TABLE IF NOT EXISTS `accounttypes` (
  `AccountFK` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `AccountTypesName` varchar(45) NOT NULL,
  `Window` int(8) unsigned NOT NULL,
  PRIMARY KEY (`AccountFK`),
  UNIQUE KEY `AccountTypesName-idx` (`AccountTypesName`),
  KEY `FK_accounttypes_accountclass` (`Window`),
  CONSTRAINT `FK_accounttypes_accountclass` FOREIGN KEY (`Window`) REFERENCES `accountclass` (`Window`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

-- Dumping data for table prototypeaccounts.accounttypes: ~1 rows (approximately)
/*!40000 ALTER TABLE `accounttypes` DISABLE KEYS */;
INSERT INTO `accounttypes` (`AccountFK`, `AccountTypesName`, `Window`) VALUES
	(3, 'AccType1', 1);
/*!40000 ALTER TABLE `accounttypes` ENABLE KEYS */;

-- Dumping structure for procedure prototypeaccounts.accountupdate
DELIMITER //
CREATE PROCEDURE `accountupdate`(
	IN `datevar` date,
	IN `amountvar` decimal(15,2),
	IN `catvar` decimal(5,1),
	IN `fullcatvar` varchar(15),
	IN `creditvar` varchar(60),
	IN `debitvar` varchar(60),
	IN `detailsvar` text,
	IN `segmentvar` varchar(30),
	IN `chequevar` decimal(15,2),
	IN `taxvar` decimal(15,2),
	IN `creddeb` varchar(10),
	IN `fxvar` DECIMAL(7,4)
)
begin 
declare creditsegmentfk, debitsegmentfk, segmentfk int(8) unsigned; 
declare taxfraction, taxamount double;   
declare userid varchar(25);
START TRANSACTION;  

set userid=substring_index(user(),'@',1);

if trim(fullcatvar)='' then set fullcatvar=null; end if;

if (segmentvar is not null) and (select count(*) from segments where segmentname=segmentvar)>0 then
   select segmentid into segmentfk from segments where segmentname=segmentvar;   
else
   set segmentfk=null;
end if;

if (creddeb='credit') then 
    set creditsegmentfk=segmentfk; 
	 set debitsegmentfk=null; 
else 
    set creditsegmentfk=null; 
	 set debitsegmentfk=segmentfk; 
end if;

if (taxvar is not null) and (taxvar>0) and (taxvar<100) then
   set taxfraction= taxvar/100;   
   set taxamount = amountvar*taxfraction/(1-taxfraction);      


insert into cashbook1(date, amount, cat, fullcat, creditfk, debitfk, details, segmentcredit, segmentdebit, cheque,fx,user)  
values (datevar, amountvar, catvar, fullcatvar, creditvar, debitvar, 
concat(detailsvar,' Automatically deducted tax at source.'), creditsegmentfk, debitsegmentfk, chequevar,fxvar,userid);  

insert into cashbook1 (date,amount,cat,fullcat,details,creditfk,debitfk,fx,user)
values( datevar,taxamount,14.3,'14.3.4',concat( 'Automatic entry ', convert(taxvar using utf8), '% tax deducted at source. CashID:',convert(last_insert_id() using utf8) ),
2933,debitvar,fxvar,'Tax:Accountupdate' );

else

insert into cashbook1(date, amount, cat, fullcat, creditfk, debitfk, details, segmentcredit, segmentdebit, cheque,fx,user)  
values (datevar, amountvar, catvar, fullcatvar, creditvar, debitvar,detailsvar, creditsegmentfk, debitsegmentfk, chequevar,fxvar,userid);  

end if;


COMMIT;  
end//
DELIMITER ;

-- Dumping structure for procedure prototypeaccounts.autoreversedeferrals
DELIMITER //
CREATE PROCEDURE `autoreversedeferrals`(IN `dt` date, IN `accvar` int(8) unsigned, IN `seg` int(8) unsigned)
    MODIFIES SQL DATA
begin
start transaction;
insert into cashbook1 (date,amount,cat,fullcat,details,creditfk,debitfk,segmentcredit,segmentdebit,segment,fx,status,autoreverse)

select dt,amount,coalesce(cat,SUBSTRING_INDEX(fullcat, '.', 2)),fullcat,concat(coalesce(details,''),' | CashID:',cashid,', Credit: ',cr,', Debit: ',dr),
accvar,creditfk,seg,segmentdebit,segment,fx,status,'A'
 from cashbook1 

inner join
(select cashid,credit cr,debit dr from joinedcashbook2 where autoreverse='R' and credit_window='12000' and creditsegment=seg) as t1
using(cashid);

update cashbook1 f 
join 
accounts s on s.accountid=creditfk
join 
accounttypes t on s.AccountFK=t.accountfk
set autoreverse='r'
#Test first before uncommenting
,details=concat('Autoreversed deferral. ',coalesce(details,''),', Cat: ',coalesce(cat,'NULL'),', Fullcat: ',coalesce(fullcat,'NULL'),', Segmentcredit: ',
coalesce(segmentcredit,'NULL'),' Segmentdebit: ',coalesce(segmentdebit,'NULL')),cat=null,fullcat=null,segmentdebit=null,segmentcredit=null

where t.window=12000 and f.autoreverse='R' and coalesce(f.segmentcredit,defaultsegment)=seg;


insert into cashbook1 (date,amount,cat,fullcat,details,creditfk,debitfk,segmentcredit,segmentdebit,segment,fx,status,autoreverse)

select dt,amount,coalesce(cat,SUBSTRING_INDEX(fullcat, '.', 2)),fullcat,concat(coalesce(details,''),' | CashID:',cashid,', Credit: ',cr,', Debit: ',dr),
debitfk,accvar,segmentcredit,seg,segment,fx,status,'A'

 from cashbook1 

inner join
(select cashid,credit cr,debit dr from joinedcashbook2 where autoreverse='R' and debit_window='12000' and debitsegment=seg) as t1
using(cashid);
update cashbook1 f 
join 
accounts s on s.accountid=debitfk
join 
accounttypes t on s.AccountFK=t.accountfk
set autoreverse='r'
#Test first before uncommenting 
,details=concat('Autoreversed deferral. ',coalesce(details,''),', Cat: ',coalesce(cat,'NULL'),', Fullcat: ',coalesce(fullcat,'NULL'),', Segmentcredit: ',
coalesce(segmentcredit,'NULL'),' Segmentdebit: ',coalesce(segmentdebit,'NULL')),cat=null,fullcat=null,segmentdebit=null,segmentcredit=null
where t.window=12000 and f.autoreverse='R' and coalesce(f.segmentdebit,defaultsegment)=seg;

commit;
end//
DELIMITER ;

-- Dumping structure for function prototypeaccounts.balancefn
DELIMITER //
CREATE FUNCTION `balancefn`( accfkvar int(8) unsigned, datevar date) RETURNS decimal(15,2)
    DETERMINISTIC
begin
declare tpos decimal (15,2);
declare tneg decimal (15,2);
declare tbal decimal (15,2);

select sum(amount) into tpos from cashbook1 where (creditfk=accfkvar and date <= datevar);

select -sum(amount) into tneg from cashbook1 where (debitfk=accfkvar and date <= datevar);
if (tpos is null) then 
set tpos = 0; 
end if;
if (tneg is null) then
set tneg = 0; 
end if;

set tbal = tneg+tpos;
return tbal;
end//
DELIMITER ;

-- Dumping structure for function prototypeaccounts.balancefnperiod
DELIMITER //
CREATE FUNCTION `balancefnperiod`( accfkvar int(8) unsigned, startdate date, finishdate date) RETURNS decimal(15,2)
    DETERMINISTIC
begin
declare tpos decimal (15,2);
declare tneg decimal (15,2);
declare tbal decimal (15,2);

select sum(amount) into tpos from cashbook1 where (creditfk=accfkvar and date <= finishdate and date >= startdate);

select -sum(amount) into tneg from cashbook1 where (debitfk=accfkvar and date <= finishdate and date >= startdate);
if (tpos is null) then 
set tpos = 0; 
end if;
if (tneg is null) then
set tneg = 0; 
end if;

set tbal = tneg+tpos;
return tbal;
end//
DELIMITER ;

-- Dumping structure for view prototypeaccounts.balances
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `balances` (
	`accountid` INT(8) UNSIGNED NOT NULL,
	`accountname` VARCHAR(60) NULL COLLATE 'latin1_bin',
	`balance` DECIMAL(15,2) NULL,
	`accounttypesname` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`accounttypesid` INT(8) UNSIGNED NOT NULL
) ENGINE=MyISAM;

-- Dumping structure for procedure prototypeaccounts.calculatePL
DELIMITER //
CREATE PROCEDURE `calculatePL`(accid int(8) unsigned)
begin
declare oldestid, newestid, soldtype int(8) unsigned;
declare oldestdt, newestdt datetime;
declare sold, bought decimal (15,3);
declare boughtfx, soldfx, PLpershare, PL_origin_per, soldunitprice, boughtunitprice double;


truncate z_sold;
truncate z_bought;
insert into z_bought(id,dt,amount,nocredited, pershare,fx)
select cashid, date_add(cast(date as datetime),interval  coalesce(transactiontime,'0:0:0') hour_second ), amount, numbercredited, amount/numbercredited, fx
from joinedcashbook2 where creditfk=accid and numbercredited>0 order by date,transactiontime;
insert into z_sold(id,dt,amount,nodebited, pershare, type,fx)
select cashid, date_add(cast(date as datetime),interval coalesce(transactiontime,'0:0:0') hour_second ), amount, numberdebited, amount/numberdebited, credit_type_fk, fx
from joinedcashbook2 where debitfk=accid and numberdebited>0 order by date,transactiontime desc;



main: loop

if (select count(*) from z_sold)=0 or (select count(*) from z_bought)=0 then
leave main; 
end if;

select id into oldestid from z_sold where dt=(select min(dt) from z_sold) limit 1;
select dt into oldestdt from z_sold where dt=(select min(dt) from z_sold) limit 1;

if (select count(*) from z_bought where dt<=oldestdt)=0 then
leave main; 
end if;

select id into newestid from z_bought where dt=(select max(dt) from z_bought where dt<=oldestdt) limit 1;
select dt into newestdt from z_bought where dt=(select max(dt) from z_bought where dt<=oldestdt) limit 1;

select nodebited into sold from z_sold where id=oldestid;
select type into soldtype from z_sold where id=oldestid;
select fx into soldfx from z_sold where id=oldestid;
select fx into boughtfx from z_bought where id=newestid;
select nocredited into bought from z_bought where id=newestid;
select z_sold.pershare into soldunitprice from z_sold where z_sold.id=oldestid;
select z_bought.pershare into boughtunitprice from z_bought where z_bought.id=newestid;

select (z_sold.pershare - z_bought.pershare) into PLpershare from z_sold,z_bought where z_sold.id=oldestid and z_bought.id=newestid;
select (soldfx*z_sold.pershare - boughtfx*z_bought.pershare) into PL_origin_per from z_sold,z_bought where z_sold.id=oldestid and z_bought.id=newestid;

if (sold < bought) then 
insert into z_PL (dt,nosold,PL,accountid,type,PL_origin,soldfx,boughtfx,boughtdate,soldunitprice,boughtunitprice,soldid,boughtid) 
values(oldestdt, sold, PLpershare*sold, accid, soldtype,PL_origin_per*sold,soldfx, boughtfx,newestdt, soldunitprice, boughtunitprice ,oldestid, newestid );
update z_bought set nocredited=nocredited-sold where id=newestid;
delete from z_sold where id=oldestid;

elseif (sold > bought) then 

insert into z_PL (dt,nosold,PL,accountid,type,PL_origin,soldfx,boughtfx,boughtdate,soldunitprice,boughtunitprice,soldid,boughtid) 
values(oldestdt, bought, PLpershare*bought, accid, soldtype,PL_origin_per*bought,soldfx,boughtfx, newestdt, soldunitprice, boughtunitprice ,oldestid, newestid  );

update z_sold set nodebited=nodebited-bought where id=oldestid;
delete from z_bought where id=newestid;

elseif (sold = bought) then 

insert into z_PL (dt,nosold,PL,accountid,type,PL_origin,soldfx,boughtfx,boughtdate,soldunitprice,boughtunitprice,soldid,boughtid ) 
values(oldestdt, sold, PLpershare*sold, accid, soldtype,PL_origin_per*sold,soldfx,boughtfx, newestdt, soldunitprice, boughtunitprice ,oldestid, newestid    );
update z_bought set nocredited=nocredited-sold where id=newestid;
delete from z_sold where id=oldestid;
delete from z_bought where id=newestid;

end if;
end loop main;
end//
DELIMITER ;

-- Dumping structure for procedure prototypeaccounts.calculatePL3
DELIMITER //
CREATE PROCEDURE `calculatePL3`()
begin
declare n, accid int(8) unsigned;
start transaction;
truncate z_PL;
set n=1;
while n<=(select count(*) from accounts where accountfk=5) do
select 0 into @row ;
select accountid into accid from (select *, @row:=@row+1 as rownum from accounts where accountfk=5 order by accountid) as te1 

where rownum=n;

call calculatePL(accid);
set n=n+1;
end while;
commit;
end//
DELIMITER ;

-- Dumping structure for table prototypeaccounts.cashbook1
CREATE TABLE IF NOT EXISTS `cashbook1` (
  `cashID` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `Date` date NOT NULL,
  `Amount` decimal(15,2) unsigned NOT NULL,
  `Cat` decimal(5,1) DEFAULT NULL,
  `FullCat` varchar(15) COLLATE latin1_bin DEFAULT NULL,
  `Credit` text COLLATE latin1_bin,
  `Debit` text COLLATE latin1_bin,
  `Details` text COLLATE latin1_bin,
  `creditFK` int(8) unsigned NOT NULL,
  `DebitFK` int(8) unsigned NOT NULL,
  `segmentcredit` int(8) unsigned DEFAULT NULL,
  `segmentdebit` int(8) unsigned DEFAULT NULL,
  `segment` varchar(25) COLLATE latin1_bin DEFAULT NULL,
  `cheque` int(10) unsigned DEFAULT NULL,
  `transactiontime` time DEFAULT NULL,
  `Numbercredited` decimal(15,3) unsigned NOT NULL DEFAULT '0.000',
  `Numberdebited` decimal(15,3) unsigned NOT NULL DEFAULT '0.000',
  `commission` decimal(8,2) unsigned DEFAULT NULL,
  `tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fx` decimal(7,4) unsigned NOT NULL DEFAULT '1.0000',
  `Status` varchar(1) COLLATE latin1_bin DEFAULT 'U',
  `Autoreverse` varchar(1) COLLATE latin1_bin DEFAULT NULL,
  `User` varchar(35) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`cashID`),
  KEY `ForeignDebit` (`DebitFK`),
  KEY `CreditForeign` (`creditFK`),
  KEY `SegmentForeign` (`segmentcredit`),
  KEY `Date-idx` (`Date`),
  KEY `Cat-idx` (`Cat`),
  KEY `amount-idx` (`Amount`),
  KEY `tstamp-idx` (`tstamp`),
  KEY `segmentdebit-idx` (`segmentdebit`),
  KEY `FullCat` (`FullCat`),
  CONSTRAINT `FK_cashbook1_segments` FOREIGN KEY (`segmentcredit`) REFERENCES `segments` (`SegmentID`),
  CONSTRAINT `FK_cashbook1_segments_2` FOREIGN KEY (`segmentdebit`) REFERENCES `segments` (`SegmentID`),
  CONSTRAINT `const1_cashbook1` FOREIGN KEY (`creditFK`) REFERENCES `accounts` (`AccountID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `const2_cashbook1` FOREIGN KEY (`DebitFK`) REFERENCES `accounts` (`AccountID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.cashbook1: ~0 rows (approximately)
/*!40000 ALTER TABLE `cashbook1` DISABLE KEYS */;
/*!40000 ALTER TABLE `cashbook1` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.catnames
CREATE TABLE IF NOT EXISTS `catnames` (
  `CatNo` decimal(5,1) NOT NULL DEFAULT '0.0',
  `CatDesc` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`CatNo`),
  UNIQUE KEY `cat-idx` (`CatNo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table prototypeaccounts.catnames: ~0 rows (approximately)
/*!40000 ALTER TABLE `catnames` DISABLE KEYS */;
/*!40000 ALTER TABLE `catnames` ENABLE KEYS */;

-- Dumping structure for view prototypeaccounts.consolidations
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `consolidations` (
	`Window` INT(8) UNSIGNED NOT NULL,
	`AccountClass` VARCHAR(35) NULL COLLATE 'latin1_swedish_ci',
	`nostro` TINYINT(1) UNSIGNED NULL,
	`balancesheet` TINYINT(1) UNSIGNED NULL,
	`asset` TINYINT(1) UNSIGNED NULL,
	`income` TINYINT(1) UNSIGNED NULL,
	`matched` TINYINT(1) UNSIGNED NULL,
	`AccountFK` INT(8) UNSIGNED NULL,
	`AccountTypesName` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;

-- Dumping structure for procedure prototypeaccounts.dailychangeinbalance
DELIMITER //
CREATE PROCEDURE `dailychangeinbalance`(in creditselect varchar(3000), in debitselect varchar(3000))
begin

set @s1='insert into z_dailyoutput select date, negbal+posbal balance from ( select date, coalesce (bal,0) negbal from (select date from listofdates where date>=\'1999-01-01\' and date<=now()) as t2 ';
set @s1=concat(@s1,' left join (select date,-sum(amount) bal from   ', debitselect , '  group by date) as t1 using(Date) ) as t3 inner join ');
set @s1=concat(@s1,' ( select date, coalesce (bal,0) posbal from (select date from listofdates where date>=\'1999-01-01\' and date<=now()) as t2 left join (select date,sum(amount) bal from     ', creditselect );
set @s1=concat(@s1,' group by date) as t1 using(Date) ) as t4 using(date); ');
truncate z_dailyoutput;
PREPARE stmt1 FROM @s1;

EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;
end//
DELIMITER ;

-- Dumping structure for view prototypeaccounts.excelshares
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `excelshares` (
	`accountid` INT(8) UNSIGNED NOT NULL,
	`Company` VARCHAR(60) NULL COLLATE 'latin1_bin',
	`Holding` DECIMAL(15,2) NULL,
	`Book Value` DECIMAL(15,2) NULL,
	`bloomberg` VARCHAR(75) NULL COLLATE 'latin1_bin'
) ENGINE=MyISAM;

-- Dumping structure for table prototypeaccounts.failed_jobs
CREATE TABLE IF NOT EXISTS `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table prototypeaccounts.failed_jobs: ~0 rows (approximately)
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;

-- Dumping structure for procedure prototypeaccounts.fairmarketvalue
DELIMITER //
CREATE PROCEDURE `fairmarketvalue`()
begin
truncate z_fmvoutput;
insert into z_fmvoutput
select accountid, epic, bookvalue, holding, dt , adjusted, adjusted*holding/100 as value, coalesce (adjusted,0)*holding/100-bookvalue as unrealizedPL from 
(select accountid, epic, bookvalue, holding, dt from prototypeaccounts.sharebalances
inner join
(select epic, max(dt) as dt from test.fmv group by epic) as t1
using(epic)) as t2
inner join
test.fmv
using(epic,dt)
order by value desc;
end//
DELIMITER ;

-- Dumping structure for function prototypeaccounts.fxbalancefn
DELIMITER //
CREATE FUNCTION `fxbalancefn`( accfkvar int(8) unsigned, datevar date) RETURNS decimal(15,2)
    DETERMINISTIC
begin
declare tpos decimal (15,2);
declare tneg decimal (15,2);
declare tbal decimal (15,2);

select sum(amount*fx) into tpos from cashbook1 where (creditfk=accfkvar and date <= datevar);

select -sum(amount*fx) into tneg from cashbook1 where (debitfk=accfkvar and date <= datevar);

if (tpos is null) then 
set tpos = 0; 
end if;
if (tneg is null) then
set tneg = 0; 
end if;

set tbal = tneg+tpos;

return tbal;
end//
DELIMITER ;

-- Dumping structure for procedure prototypeaccounts.getaccountfk
DELIMITER //
CREATE PROCEDURE `getaccountfk`(in inputvar varchar(60) )
begin
select accountid from accounts where (accountname = trim(inputvar)) limit 35;
end//
DELIMITER ;

-- Dumping structure for table prototypeaccounts.importcash
CREATE TABLE IF NOT EXISTS `importcash` (
  `dt` date DEFAULT NULL,
  `am` decimal(15,2) DEFAULT NULL,
  `ct` decimal(5,1) DEFAULT NULL,
  `fct` varchar(15) COLLATE latin1_bin DEFAULT NULL,
  `deb` text COLLATE latin1_bin,
  `cred` text COLLATE latin1_bin,
  `det` text COLLATE latin1_bin,
  `seg` varchar(25) COLLATE latin1_bin DEFAULT NULL,
  `che` int(10) unsigned DEFAULT NULL,
  `pk` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `swap` text COLLATE latin1_bin,
  PRIMARY KEY (`pk`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.importcash: ~0 rows (approximately)
/*!40000 ALTER TABLE `importcash` DISABLE KEYS */;
/*!40000 ALTER TABLE `importcash` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.iso3166
CREATE TABLE IF NOT EXISTS `iso3166` (
  `countrycode` varchar(2) NOT NULL,
  `countryname` varchar(50) NOT NULL,
  PRIMARY KEY (`countrycode`),
  UNIQUE KEY `countrycode` (`countrycode`),
  KEY `countrycode_2` (`countrycode`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Country codes';

-- Dumping data for table prototypeaccounts.iso3166: ~0 rows (approximately)
/*!40000 ALTER TABLE `iso3166` DISABLE KEYS */;
/*!40000 ALTER TABLE `iso3166` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.iso4217
CREATE TABLE IF NOT EXISTS `iso4217` (
  `currencycode` varchar(3) CHARACTER SET latin1 NOT NULL,
  `numericcode` int(3) unsigned NOT NULL,
  `currencyname` varchar(50) CHARACTER SET latin1 NOT NULL,
  `countries` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `symbol` varchar(3) DEFAULT NULL,
  `currencyshort` varchar(3) DEFAULT NULL,
  PRIMARY KEY (`currencycode`),
  UNIQUE KEY `currencycode` (`currencycode`),
  UNIQUE KEY `numeric-idx` (`numericcode`),
  KEY `currencycode_2` (`currencycode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Currencyshort column is used to deal with $,£, being written rather than GBP, USD. Can''t used the symbol column as not unique - other contries use $, eg. Hong Kong.';

-- Dumping data for table prototypeaccounts.iso4217: ~0 rows (approximately)
/*!40000 ALTER TABLE `iso4217` DISABLE KEYS */;
/*!40000 ALTER TABLE `iso4217` ENABLE KEYS */;

-- Dumping structure for view prototypeaccounts.joinedcashbook
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `joinedcashbook` (
	`cashid` INT(8) UNSIGNED NOT NULL,
	`date` DATE NOT NULL,
	`amount` DECIMAL(15,2) UNSIGNED NOT NULL,
	`cat` DECIMAL(5,1) NULL,
	`catdesc` VARCHAR(80) NULL COLLATE 'latin1_swedish_ci',
	`fullcat` VARCHAR(15) NULL COLLATE 'latin1_bin',
	`creditfk` INT(8) UNSIGNED NOT NULL,
	`credit` VARCHAR(60) NULL COLLATE 'latin1_bin',
	`credit_type` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`credit_type_FK` INT(8) UNSIGNED NOT NULL,
	`credit_currency` VARCHAR(3) NULL COLLATE 'latin1_bin',
	`debitfk` INT(8) UNSIGNED NOT NULL,
	`debit` VARCHAR(60) NULL COLLATE 'latin1_bin',
	`debit_type` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`debit_type_FK` INT(8) UNSIGNED NOT NULL,
	`debit_currency` VARCHAR(3) NULL COLLATE 'latin1_bin',
	`details` TEXT NULL COLLATE 'latin1_bin',
	`segment` VARCHAR(25) NULL COLLATE 'latin1_bin',
	`segmentname` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`segmentfk` INT(8) UNSIGNED NULL,
	`cheque` INT(10) UNSIGNED NULL,
	`transactiontime` TIME NULL,
	`numbercredited` DECIMAL(15,3) UNSIGNED NOT NULL,
	`numberdebited` DECIMAL(15,3) UNSIGNED NOT NULL,
	`commission` DECIMAL(8,2) UNSIGNED NULL,
	`fx` DECIMAL(7,4) UNSIGNED NOT NULL,
	`tstamp` TIMESTAMP NOT NULL
) ENGINE=MyISAM;

-- Dumping structure for view prototypeaccounts.joinedcashbook2
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `joinedcashbook2` (
	`cashid` INT(8) UNSIGNED NOT NULL,
	`date` DATE NOT NULL,
	`amount` DECIMAL(15,2) UNSIGNED NOT NULL,
	`cat` DECIMAL(5,1) NULL,
	`fullcat` VARCHAR(15) NULL COLLATE 'latin1_bin',
	`catdesc` VARCHAR(80) NULL COLLATE 'latin1_swedish_ci',
	`credit` VARCHAR(60) NULL COLLATE 'latin1_bin',
	`debit` VARCHAR(60) NULL COLLATE 'latin1_bin',
	`details` TEXT NULL COLLATE 'latin1_bin',
	`creditfk` INT(8) UNSIGNED NOT NULL,
	`debitfk` INT(8) UNSIGNED NOT NULL,
	`creditsegment` BIGINT(10) UNSIGNED NULL,
	`Credit_SegName` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`Credit_SegGrpID` INT(8) UNSIGNED NULL,
	`Credit_SegGrp` VARCHAR(35) NULL COLLATE 'latin1_swedish_ci',
	`debitsegment` BIGINT(10) UNSIGNED NULL,
	`Debit_SegName` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`Debit_SegGrpID` INT(8) UNSIGNED NULL,
	`Debit_SegGrp` VARCHAR(35) NULL COLLATE 'latin1_swedish_ci',
	`cheque` INT(10) UNSIGNED NULL,
	`transactiontime` TIME NULL,
	`numbercredited` DECIMAL(15,3) UNSIGNED NOT NULL,
	`numberdebited` DECIMAL(15,3) UNSIGNED NOT NULL,
	`commission` DECIMAL(8,2) UNSIGNED NULL,
	`fx` DECIMAL(7,4) UNSIGNED NOT NULL,
	`status` VARCHAR(1) NULL COLLATE 'latin1_bin',
	`autoreverse` VARCHAR(1) NULL COLLATE 'latin1_bin',
	`credit_Type_FK` INT(8) UNSIGNED NOT NULL,
	`credit_window` INT(8) UNSIGNED NOT NULL,
	`credit_currency` VARCHAR(3) NULL COLLATE 'latin1_bin',
	`credit_taxcountry` VARCHAR(2) NULL COLLATE 'latin1_bin',
	`credit_type` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`credit_nostro` TINYINT(1) UNSIGNED NULL,
	`credit_balancesheet` TINYINT(1) UNSIGNED NULL,
	`credit_asset` TINYINT(1) UNSIGNED NULL,
	`credit_income` TINYINT(1) UNSIGNED NULL,
	`credit_matched` TINYINT(1) UNSIGNED NULL,
	`debit_Type_FK` INT(8) UNSIGNED NOT NULL,
	`debit_window` INT(8) UNSIGNED NOT NULL,
	`debit_currency` VARCHAR(3) NULL COLLATE 'latin1_bin',
	`debit_taxcountry` VARCHAR(2) NULL COLLATE 'latin1_bin',
	`debit_type` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`debit_nostro` TINYINT(1) UNSIGNED NULL,
	`debit_balancesheet` TINYINT(1) UNSIGNED NULL,
	`debit_asset` TINYINT(1) UNSIGNED NULL,
	`debit_income` TINYINT(1) UNSIGNED NULL,
	`debit_matched` TINYINT(1) UNSIGNED NULL
) ENGINE=MyISAM;

-- Dumping structure for table prototypeaccounts.joinedcat_table
CREATE TABLE IF NOT EXISTS `joinedcat_table` (
  `pk` int(8) unsigned NOT NULL DEFAULT '0',
  `catpk` varchar(20) COLLATE latin1_bin NOT NULL,
  `coicop` int(5) unsigned NOT NULL DEFAULT '0',
  `cat` decimal(5,1) unsigned NOT NULL DEFAULT '0.0',
  `subcat` varchar(20) COLLATE latin1_bin DEFAULT '',
  `fullcat` varchar(20) COLLATE latin1_bin DEFAULT '',
  `coicop_details` text COLLATE latin1_bin,
  `cat_details` text COLLATE latin1_bin,
  `subcat_details` text COLLATE latin1_bin,
  `fullcat_details` text COLLATE latin1_bin,
  PRIMARY KEY (`pk`),
  UNIQUE KEY `catpk` (`catpk`),
  UNIQUE KEY `fullcat` (`fullcat`),
  KEY `cat` (`cat`),
  KEY `subcat` (`subcat`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.joinedcat_table: ~0 rows (approximately)
/*!40000 ALTER TABLE `joinedcat_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `joinedcat_table` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.listofdates
CREATE TABLE IF NOT EXISTS `listofdates` (
  `date` date NOT NULL,
  `am` decimal(15,2) NOT NULL DEFAULT '0.00',
  `holidays` int(2) unsigned zerofill NOT NULL,
  `lastworking` date DEFAULT NULL,
  `nextworking` date DEFAULT NULL,
  `taxyear` int(4) unsigned DEFAULT NULL,
  PRIMARY KEY (`date`),
  UNIQUE KEY `dt` (`date`),
  KEY `dt_2` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table prototypeaccounts.listofdates: ~0 rows (approximately)
/*!40000 ALTER TABLE `listofdates` DISABLE KEYS */;
/*!40000 ALTER TABLE `listofdates` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.listoftimes
CREATE TABLE IF NOT EXISTS `listoftimes` (
  `tm` time NOT NULL,
  PRIMARY KEY (`tm`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.listoftimes: ~0 rows (approximately)
/*!40000 ALTER TABLE `listoftimes` DISABLE KEYS */;
/*!40000 ALTER TABLE `listoftimes` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.migrations
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table prototypeaccounts.migrations: ~14 rows (approximately)
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
	(1, '2014_10_12_000000_create_users_table', 1),
	(2, '2014_10_12_100000_create_password_resets_table', 1),
	(3, '2019_08_19_000000_create_failed_jobs_table', 1),
	(4, '2022_01_02_163848_create_accounttypes_table', 2),
	(5, '2022_01_02_163903_create_accountclasses_table', 2),
	(6, '2022_01_02_163920_create_accounts_table', 3),
	(7, '2022_01_02_174108_update_accounttypes_foreign_key', 4),
	(8, '2022_01_02_175741_update_accountclass_add_foreign_key', 5),
	(9, '2022_01_03_115008_create_segment_table', 6),
	(10, '2022_01_03_115121_create_cashbook1_table', 7),
	(11, '2022_01_03_121704_update_cashbook1_foreign_key', 8),
	(12, '2022_01_03_160406_create_segmentgroups_table', 9),
	(13, '2022_01_04_174507_create_catnames_table', 10),
	(14, '2022_01_04_175441_update_cashbook1_table_add_date_field', 11);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;

-- Dumping structure for procedure prototypeaccounts.newaccount
DELIMITER //
CREATE PROCEDURE `newaccount`(
	IN `datevar` date,
	IN `amountvar` decimal(15,2),
	IN `catvar` decimal(5,1),
	IN `fullcatvar` varchar(15),
	IN `fromvar` varchar(60),
	IN `accountvar` int(8) unsigned,
	IN `accounttypeidvar` int(8) unsigned,
	IN `creddeb` varchar(10),
	IN `detailsvar` text,
	IN `segmentvar` varchar(30),
	IN `chequevar` decimal(15,2),
	IN `taxvar` decimal(15,2),
	IN `fxvar` DECIMAL(7,4)
)
begin 
declare t1, creditvar, debitvar, segmentfk int(8) unsigned;   
declare taxfraction, taxamount double;
declare userid varchar(25);
START TRANSACTION; 

set userid=substring_index(user(),'@',1);

if trim(fullcatvar)='' then set fullcatvar=null; end if;

insert into accounts(accountname, accountfk) values (fromvar, accounttypeidvar);  
select accountid into t1 from accounts where accountname=fromvar; 

if (segmentvar is not null) and (select count(*) from segments where segmentname=segmentvar)>0 then
   select segmentid into segmentfk from segments where segmentname=segmentvar;   
else
   set segmentfk=null;
end if;


if (creddeb='credit') then  

  set creditvar=t1; 
  set debitvar=accountvar;

  insert into cashbook1(date, amount, cat, fullcat, creditfk, debitfk, details, segmentcredit, cheque,fx,user)  
  values (datevar, amountvar, catvar, fullcatvar, creditvar, debitvar,  detailsvar, segmentfk, chequevar,fxvar,userid);  

elseif (creddeb='debit') then

  set creditvar=accountvar; 
  set debitvar=t1; 
  
  if (taxvar is not null) and (taxvar>0) and (taxvar<100) then
     set taxfraction= taxvar/100;   
     set taxamount = amountvar*taxfraction/(1-taxfraction);      


      insert into cashbook1(date, amount, cat, fullcat, creditfk, debitfk, details, segmentdebit, cheque,fx,user)  
      values (datevar, amountvar, catvar, fullcatvar, creditvar, debitvar, 
      concat(detailsvar,' Automatically deducted tax at source.'), segmentfk, chequevar,fxvar,userid);  

      insert into cashbook1 (date,amount,cat,fullcat,details,creditfk,debitfk,fx,user)
      values( datevar,taxamount,14.3,'14.3.4',concat( 'Automatic entry ', convert(taxvar using utf8), '% tax deducted at source. CashID:',convert(last_insert_id() using utf8) ),
      2933,debitvar,fxvar,'Tax:Newaccount' );

   else

      insert into cashbook1(date, amount, cat, fullcat, creditfk, debitfk, details, segmentdebit, cheque,fx,user)  
      values (datevar, amountvar, catvar, fullcatvar, creditvar, debitvar,detailsvar, segmentfk, chequevar,fxvar,userid);  
   end if;
	
end if;  

commit;
end//
DELIMITER ;

-- Dumping structure for procedure prototypeaccounts.newshare
DELIMITER //
CREATE PROCEDURE `newshare`(in datevar date, in amountvar decimal(15,2), in fromvar varchar(60), in accountvar int(8) unsigned, in accounttypeidvar int(8) unsigned, 
in creddeb varchar(10), in detailsvar text, in segmentvar varchar(25), in bloombergvar varchar(75), in shareidvar int(8) unsigned, in numbercreditedvar decimal(15,3), 
in numberdebitedvar decimal(15,3), in commissionvar decimal(15,2), 
in fxvar decimal(5,4), in transactiontimevar time, in currencyvar varchar(3))
begin  
declare t1 int(8) unsigned;   
START TRANSACTION; 
insert into accounts(accountname, accountfk, defaultsegment, bloomberg, currency) 
values (fromvar, accounttypeidvar, shareidvar, bloombergvar, currencyvar); 
select accountid into t1 from accounts where accountname=fromvar; 
if (creddeb='debit') then   
    insert into cashbook1(date, amount, creditfk, debitfk, details, segment, numbercredited, numberdebited, commission, fx, transactiontime)
    values (datevar, amountvar, t1, accountvar, detailsvar, segmentvar, numbercreditedvar, numberdebitedvar, commissionvar, fxvar, transactiontimevar); 
else
   insert into cashbook1(date, amount, creditfk, debitfk, details, segment, numbercredited, numberdebited, commission, fx, transactiontime)  
	values (datevar, amountvar, accountvar, t1, detailsvar, segmentvar, numbercreditedvar, numberdebitedvar, commissionvar, fxvar, transactiontimevar); 
end if; 
COMMIT;  
end//
DELIMITER ;

-- Dumping structure for table prototypeaccounts.password_resets
CREATE TABLE IF NOT EXISTS `password_resets` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  KEY `password_resets_email_index` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table prototypeaccounts.password_resets: ~0 rows (approximately)
/*!40000 ALTER TABLE `password_resets` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_resets` ENABLE KEYS */;

-- Dumping structure for view prototypeaccounts.prelimjoinedcashbook
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `prelimjoinedcashbook` (
	`cashid` INT(8) UNSIGNED NOT NULL,
	`date` DATE NOT NULL,
	`amount` DECIMAL(15,2) UNSIGNED NOT NULL,
	`cat` DECIMAL(5,1) NULL,
	`fullcat` VARCHAR(15) NULL COLLATE 'latin1_bin',
	`catdesc` VARCHAR(80) NULL COLLATE 'latin1_swedish_ci',
	`credit` VARCHAR(60) NULL COLLATE 'latin1_bin',
	`debit` VARCHAR(60) NULL COLLATE 'latin1_bin',
	`details` TEXT NULL COLLATE 'latin1_bin',
	`creditfk` INT(8) UNSIGNED NOT NULL,
	`debitfk` INT(8) UNSIGNED NOT NULL,
	`creditsegment` BIGINT(10) UNSIGNED NULL,
	`debitsegment` BIGINT(10) UNSIGNED NULL,
	`cheque` INT(10) UNSIGNED NULL,
	`transactiontime` TIME NULL,
	`numbercredited` DECIMAL(15,3) UNSIGNED NOT NULL,
	`numberdebited` DECIMAL(15,3) UNSIGNED NOT NULL,
	`commission` DECIMAL(8,2) UNSIGNED NULL,
	`fx` DECIMAL(7,4) UNSIGNED NOT NULL,
	`status` VARCHAR(1) NULL COLLATE 'latin1_bin',
	`autoreverse` VARCHAR(1) NULL COLLATE 'latin1_bin',
	`credit_Type_FK` INT(8) UNSIGNED NOT NULL,
	`credit_window` INT(8) UNSIGNED NOT NULL,
	`credit_currency` VARCHAR(3) NULL COLLATE 'latin1_bin',
	`credit_taxcountry` VARCHAR(2) NULL COLLATE 'latin1_bin',
	`credit_type` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`credit_nostro` TINYINT(1) UNSIGNED NULL,
	`credit_balancesheet` TINYINT(1) UNSIGNED NULL,
	`credit_asset` TINYINT(1) UNSIGNED NULL,
	`credit_income` TINYINT(1) UNSIGNED NULL,
	`credit_matched` TINYINT(1) UNSIGNED NULL,
	`debit_Type_FK` INT(8) UNSIGNED NOT NULL,
	`debit_window` INT(8) UNSIGNED NOT NULL,
	`debit_currency` VARCHAR(3) NULL COLLATE 'latin1_bin',
	`debit_taxcountry` VARCHAR(2) NULL COLLATE 'latin1_bin',
	`debit_type` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`debit_nostro` TINYINT(1) UNSIGNED NULL,
	`debit_balancesheet` TINYINT(1) UNSIGNED NULL,
	`debit_asset` TINYINT(1) UNSIGNED NULL,
	`debit_income` TINYINT(1) UNSIGNED NULL,
	`debit_matched` TINYINT(1) UNSIGNED NULL
) ENGINE=MyISAM;

-- Dumping structure for procedure prototypeaccounts.quickaccounts
DELIMITER //
CREATE PROCEDURE `quickaccounts`(IN `startdate` date, IN `finishdate` date)
begin
truncate z_quickaccountsoutput;
insert into z_quickaccountsoutput
select window,accountclass,nostro,balancesheet,asset,income,matched,coalesce( bookvalue_transactionvalue,0)  from
accountclass
left join
(select window , sum(balance) bookvalue_transactionvalue from (
(select window, -balancefnperiod(accountid,startdate,finishdate) balance from accountsjoined where income>=1)

union all
(select window, balancefn(accountid,finishdate) balance from accountsjoined where asset in (1,2) )

union all

(select 30000, sum(am) from
((select -coalesce(sum(amount),0) am from joinedcashbook2 where debit_nostro=1 and credit_nostro=0 and date<=finishdate)
union all
(select +coalesce(sum(amount),0) am from joinedcashbook2 where debit_nostro=0 and credit_nostro=1 and date<=finishdate)) as t3)
                                                                            
                                                                                                                                     

union all
(select 30000, -balancefn(2931,finishdate))



) as t1 group by window) as t2
using(window);
end//
DELIMITER ;

-- Dumping structure for function prototypeaccounts.segbalancefnper
DELIMITER //
CREATE FUNCTION `segbalancefnper`(seg int(8) unsigned,startdate date, finishdate date) RETURNS decimal(15,2)
    DETERMINISTIC
begin
declare tpos, tneg,tbal decimal (15,2);

select coalesce (sum(amount),0) into tpos from joinedcashbook2 where (creditsegment=seg and date <= finishdate and date >= startdate);

select coalesce (-sum(amount),0) into tneg from joinedcashbook2 where (debitsegment=seg and date <= finishdate and date >= startdate);
set tbal = tneg+tpos;
return tbal;

end//
DELIMITER ;

-- Dumping structure for table prototypeaccounts.segmentgroups
CREATE TABLE IF NOT EXISTS `segmentgroups` (
  `SegmentGroupsID` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `SegmentGroup` varchar(35) NOT NULL,
  PRIMARY KEY (`SegmentGroupsID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

-- Dumping data for table prototypeaccounts.segmentgroups: ~0 rows (approximately)
/*!40000 ALTER TABLE `segmentgroups` DISABLE KEYS */;
INSERT INTO `segmentgroups` (`SegmentGroupsID`, `SegmentGroup`) VALUES
	(5, 'SegmentGroup 1');
/*!40000 ALTER TABLE `segmentgroups` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.segments
CREATE TABLE IF NOT EXISTS `segments` (
  `SegmentID` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `SegmentName` varchar(45) NOT NULL,
  `SegmentGroupsID` int(8) unsigned NOT NULL,
  PRIMARY KEY (`SegmentID`),
  UNIQUE KEY `segmentname-idx` (`SegmentName`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table prototypeaccounts.segments: ~0 rows (approximately)
/*!40000 ALTER TABLE `segments` DISABLE KEYS */;
INSERT INTO `segments` (`SegmentID`, `SegmentName`, `SegmentGroupsID`) VALUES
	(1, 'Segment 1', 5);
/*!40000 ALTER TABLE `segments` ENABLE KEYS */;

-- Dumping structure for view prototypeaccounts.segmentsjoined
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `segmentsjoined` (
	`SegmentGroupsID` INT(8) UNSIGNED NOT NULL,
	`SegmentID` INT(8) UNSIGNED NOT NULL,
	`SegmentName` VARCHAR(45) NOT NULL COLLATE 'latin1_swedish_ci',
	`SegmentGroup` VARCHAR(35) NOT NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;

-- Dumping structure for view prototypeaccounts.sharebalances
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `sharebalances` (
	`companyname` VARCHAR(45) NULL COLLATE 'latin1_swedish_ci',
	`BookValue` DECIMAL(15,2) NULL,
	`accountid` INT(8) UNSIGNED NOT NULL,
	`epic` VARCHAR(20) NULL COLLATE 'latin1_bin',
	`accountname` VARCHAR(60) NULL COLLATE 'latin1_bin',
	`Holding` DECIMAL(15,2) NULL
) ENGINE=MyISAM;

-- Dumping structure for function prototypeaccounts.sharebalfn
DELIMITER //
CREATE FUNCTION `sharebalfn`( accfkvar int(8) unsigned, datevar date) RETURNS decimal(15,2)
    DETERMINISTIC
begin
declare tpos decimal (15,2);
declare tneg decimal (15,2);
declare tbal decimal (15,2);

select sum(numbercredited) into tpos from cashbook1 where (creditfk=accfkvar and date <= datevar);

select -sum(numberdebited) into tneg from cashbook1 where (debitfk=accfkvar and date <= datevar);
if (tpos is null) then 
set tpos = 0; 
end if;
if (tneg is null) then
set tneg = 0; 
end if;

set tbal = tneg+tpos;
return tbal;
end//
DELIMITER ;

-- Dumping structure for function prototypeaccounts.sharebal_at_date_fn
DELIMITER //
CREATE FUNCTION `sharebal_at_date_fn`( datevar date) RETURNS decimal(15,2)
    DETERMINISTIC
begin
declare total decimal (15,2);


select sum(value) into total from
(


select epic,dt nearest_available_date,accountid, unadjusted, sharebalfn(accountid,dt) holding, sharebalfn(accountid,dt)*unadjusted/100 value from
(select epic, dt, unadjusted from

(
select e1, convert(coalesce (dt, rightdt) using utf8) nearest_dt from
(select epic e1,convert(subdate(datevar,absdt) using utf8) leftdt, convert(adddate(datevar,absdt) using utf8) rightdt from
(select epic,min(abs(datediff(dt,datevar))) absdt from test.fmv  group by epic) as t1) as t2
left join
test.fmv
on epic=e1 and leftdt=dt
) as t2a


left join
test.fmv 
on epic=e1
and dt=nearest_dt) as t3
inner join 
accountsjoined
using(epic) 



) as t4 limit 1;

if (total is null) then set total = 0; end if;

return total;
end//
DELIMITER ;

-- Dumping structure for procedure prototypeaccounts.sharebal_at_date_proc
DELIMITER //
CREATE PROCEDURE `sharebal_at_date_proc`(datevar date)
begin
select epic,dt nearest_available_date,accountid, unadjusted, sharebalfn(accountid,dt) holding, sharebalfn(accountid,dt)*unadjusted/100 value from
(select epic, dt, unadjusted from


(
select e1, convert(coalesce (dt, rightdt) using utf8) nearest_dt from
(select epic e1,convert(subdate(datevar,absdt) using utf8) leftdt, convert(adddate(datevar,absdt) using utf8) rightdt from
(select epic,min(abs(datediff(dt,datevar))) absdt from test.fmv  group by epic) as t1) as t2
left join
test.fmv
on epic=e1 and leftdt=dt
) as t2a



left join
test.fmv 
on epic=e1
and dt=nearest_dt) as t3
inner join 
accountsjoined
using(epic); 
end//
DELIMITER ;

-- Dumping structure for procedure prototypeaccounts.shareupdate
DELIMITER //
CREATE PROCEDURE `shareupdate`(in datevar date,
in amountvar decimal(15,2),
in creditvar int(8) unsigned,
in debitvar int(8) unsigned,
in detailsvar text,
in segmentvar varchar(25),
in numbercreditedvar decimal(15,3),
in numberdebitedvar decimal(15,3),
in commissionvar decimal(15,2),
in fxvar decimal(5,4),
in transactiontimevar time)
begin


 
START TRANSACTION;

insert into cashbook1(date, amount, creditfk, debitfk, details, segment, numbercredited, numberdebited, commission, fx, transactiontime) 
values (datevar, amountvar, creditvar, debitvar, detailsvar, segmentvar, numbercreditedvar, numberdebitedvar, commissionvar, fxvar, transactiontimevar);
COMMIT;

end//
DELIMITER ;

-- Dumping structure for procedure prototypeaccounts.statementtidy
DELIMITER //
CREATE PROCEDURE `statementtidy`( in d1 date,
in d2 date,
in fk int(8) unsigned)
begin

select cashid, date, amount, catdesc, fullcat, cred.AccountName 'credit A/C', cred.accounttypesname 'credit_type', 
accounts.accountname 'debit A/C', accounttypes.accounttypesname 'debit_type', details, segmentname, cheque, transactiontime,
numbercredited, numberdebited, commission, fx, debitfk, creditfk

  from ((select * from cashbook1 
left join catnames on cat=catno 
left join segments on segmentfk=segmentid
inner join accounts on creditfk=accountid

inner join accounttypes on accountFK=accounttypesID
inner join accountclass on accounttypesFK=accountclassID

left join shares on stocknameFK=shareID where (date >=d1 and date <= d2)) as cred 
inner join accounts on cred.debitfk=accounts.accountid

inner join accounttypes on accounts.accountFK=accounttypes.accounttypesID
inner join accountclass on accounttypes.accounttypesFK=accountclass.accountclassID

left join shares on accounts.stocknameFK=shares.shareID) where ((cred.accountid=fk) or (accounts.accountid=fk)) order by date asc;
end//
DELIMITER ;

-- Dumping structure for procedure prototypeaccounts.statementtidy4
DELIMITER //
CREATE PROCEDURE `statementtidy4`( in startdate date, in finishdate date, in accvar int(8) unsigned)
begin

select 0 into @running_total;
select * from joinedcashbook
inner join 
(SELECT  date, Added, @running_total := @running_total + Added AS running_sum  FROM 

(SELECT date, sum(posneg) AS Added FROM
	 
(select cashid, date, -amount as posneg from cashbook1 where debitfk=accvar
union
select cashid, date, amount from cashbook1 where creditfk=accvar) as t1
   
	GROUP BY date ) AS t2) as f
using (date)  where ((debitfk=accvar or creditfk=accvar) and date >= startdate and date <= finishdate) 
order by date;

end//
DELIMITER ;

-- Dumping structure for procedure prototypeaccounts.suggest
DELIMITER //
CREATE PROCEDURE `suggest`(in inputvar varchar(60), in divSafe varchar(10))
begin
if (divSafe='true') then 
select accountname, accounttypesname from accountsjoined 
where ((lower(accountname) like concat(lower(inputvar),'%')) and accountfk<>5) limit 35;
else
select accountname, accounttypesname from accountsjoined 
where (lower(accountname) like concat(lower(inputvar),'%')) limit 35;
end if;

end//
DELIMITER ;

-- Dumping structure for table prototypeaccounts.suggesttax
CREATE TABLE IF NOT EXISTS `suggesttax` (
  `actype` int(8) unsigned NOT NULL DEFAULT '0',
  `country` varchar(2) COLLATE latin1_bin NOT NULL DEFAULT '',
  `percent` decimal(15,4) DEFAULT NULL,
  `comment` varchar(50) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`actype`,`country`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.suggesttax: ~0 rows (approximately)
/*!40000 ALTER TABLE `suggesttax` DISABLE KEYS */;
/*!40000 ALTER TABLE `suggesttax` ENABLE KEYS */;

-- Dumping structure for procedure prototypeaccounts.tax_return
DELIMITER //
CREATE PROCEDURE `tax_return`(IN `yearend` int(4))
begin
select *, net+tax gross, round( tax*100/(net+tax),2) rateoftax from
(
select date,
debit,Debit_SegGrp,debit_currency,debit_taxcountry,sum(amount) net from joinedcashbook2 where debit_window in(40000,45000)                                                             
and date>=concat(convert(yearend-1 using utf8),'-04-05') and date<=concat(convert(yearend using utf8),'-04-05')                        
and creditfk<>2933                                                                                                                                       
and creditfk not in (2216,2487,3357,3392,3393,3452,3484)                           
 group by debit                                                                            
 order by Debit_SegGrpID,debit_taxcountry desc,debit                  
) as t1
left join
(
select debit,sum(amount) tax from joinedcashbook2 where debit_window in(40000,45000)                                                             
and date>=concat(convert(yearend-1 using utf8),'-04-05') and date<=concat(convert(yearend using utf8),'-04-05')                        
and creditfk=2933                                                                                                                                       
and creditfk not in (2216,2487,3357,3392,3393,3452,3484)                           
 group by debit                                                                            
 order by debit                  
)
as t2
using(debit);
end//
DELIMITER ;

-- Dumping structure for table prototypeaccounts.toplevelcatnames
CREATE TABLE IF NOT EXISTS `toplevelcatnames` (
  `maincatno` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `maincatdesc` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`maincatno`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table prototypeaccounts.toplevelcatnames: ~0 rows (approximately)
/*!40000 ALTER TABLE `toplevelcatnames` DISABLE KEYS */;
/*!40000 ALTER TABLE `toplevelcatnames` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table prototypeaccounts.users: ~0 rows (approximately)
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.z_bought
CREATE TABLE IF NOT EXISTS `z_bought` (
  `id` int(8) unsigned NOT NULL,
  `dt` datetime DEFAULT NULL,
  `amount` decimal(15,2) unsigned DEFAULT NULL,
  `nocredited` decimal(15,3) DEFAULT NULL,
  `pershare` double DEFAULT NULL,
  `fx` decimal(7,4) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.z_bought: ~0 rows (approximately)
/*!40000 ALTER TABLE `z_bought` DISABLE KEYS */;
/*!40000 ALTER TABLE `z_bought` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.z_dailyoutput
CREATE TABLE IF NOT EXISTS `z_dailyoutput` (
  `date` date NOT NULL DEFAULT '0000-00-00',
  `amount` decimal(15,2) DEFAULT NULL,
  PRIMARY KEY (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.z_dailyoutput: ~0 rows (approximately)
/*!40000 ALTER TABLE `z_dailyoutput` DISABLE KEYS */;
/*!40000 ALTER TABLE `z_dailyoutput` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.z_fmvoutput
CREATE TABLE IF NOT EXISTS `z_fmvoutput` (
  `accountid` int(8) unsigned NOT NULL DEFAULT '0',
  `epic` varchar(10) COLLATE latin1_bin DEFAULT NULL,
  `bookvalue` decimal(15,2) DEFAULT NULL,
  `holding` decimal(15,3) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `adjusted` decimal(15,2) DEFAULT NULL,
  `value` decimal(15,2) DEFAULT NULL,
  `UnrealizedPL` decimal(15,2) DEFAULT NULL COMMENT 'Unrealized PL',
  PRIMARY KEY (`accountid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.z_fmvoutput: ~0 rows (approximately)
/*!40000 ALTER TABLE `z_fmvoutput` DISABLE KEYS */;
/*!40000 ALTER TABLE `z_fmvoutput` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.z_pl
CREATE TABLE IF NOT EXISTS `z_pl` (
  `id` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `dt` datetime DEFAULT NULL,
  `nosold` decimal(15,3) DEFAULT NULL,
  `PL` decimal(15,2) DEFAULT NULL,
  `accountid` int(8) unsigned DEFAULT NULL,
  `type` int(8) unsigned DEFAULT NULL,
  `PL_origin` decimal(15,2) DEFAULT NULL,
  `soldfx` decimal(7,4) unsigned DEFAULT NULL,
  `boughtfx` decimal(7,4) unsigned DEFAULT NULL,
  `boughtdate` datetime DEFAULT NULL,
  `soldunitprice` double DEFAULT NULL,
  `boughtunitprice` double DEFAULT NULL,
  `soldid` int(8) unsigned DEFAULT NULL,
  `boughtid` int(8) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.z_pl: ~0 rows (approximately)
/*!40000 ALTER TABLE `z_pl` DISABLE KEYS */;
/*!40000 ALTER TABLE `z_pl` ENABLE KEYS */;

-- Dumping structure for view prototypeaccounts.z_pljoined
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `z_pljoined` (
	`accountid` INT(8) UNSIGNED NULL,
	`id` INT(8) UNSIGNED NOT NULL,
	`dt` DATETIME NULL,
	`nosold` DECIMAL(15,3) NULL,
	`PL` DECIMAL(15,2) NULL,
	`type` INT(8) UNSIGNED NULL,
	`PL_origin` DECIMAL(15,2) NULL,
	`soldfx` DECIMAL(7,4) UNSIGNED NULL,
	`boughtfx` DECIMAL(7,4) UNSIGNED NULL,
	`boughtdate` DATETIME NULL,
	`soldunitprice` DOUBLE NULL,
	`boughtunitprice` DOUBLE NULL,
	`soldid` INT(8) UNSIGNED NULL,
	`boughtid` INT(8) UNSIGNED NULL,
	`AccountName` VARCHAR(60) NULL COLLATE 'latin1_bin',
	`AccountFK` INT(8) UNSIGNED NOT NULL,
	`DefaultSegment` INT(8) UNSIGNED NULL,
	`bloomberg` VARCHAR(75) NULL COLLATE 'latin1_bin',
	`epic` VARCHAR(20) NULL COLLATE 'latin1_bin',
	`tstampaccounts` TIMESTAMP NOT NULL,
	`currency` VARCHAR(3) NULL COLLATE 'latin1_bin',
	`Taxcountry` VARCHAR(2) NULL COLLATE 'latin1_bin',
	`primary_pl` DECIMAL(23,6) NULL,
	`fx_pl` DECIMAL(24,6) NULL
) ENGINE=MyISAM;

-- Dumping structure for table prototypeaccounts.z_quickaccountsoutput
CREATE TABLE IF NOT EXISTS `z_quickaccountsoutput` (
  `window` int(8) unsigned NOT NULL DEFAULT '0',
  `accountclass` varchar(35) COLLATE latin1_bin DEFAULT NULL,
  `nostro` tinyint(1) unsigned DEFAULT NULL,
  `balancesheet` tinyint(1) unsigned DEFAULT NULL,
  `asset` tinyint(1) unsigned DEFAULT NULL,
  `income` tinyint(1) unsigned DEFAULT NULL,
  `matched` tinyint(1) unsigned DEFAULT NULL,
  `total` decimal(15,2) DEFAULT NULL,
  PRIMARY KEY (`window`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.z_quickaccountsoutput: ~0 rows (approximately)
/*!40000 ALTER TABLE `z_quickaccountsoutput` DISABLE KEYS */;
/*!40000 ALTER TABLE `z_quickaccountsoutput` ENABLE KEYS */;

-- Dumping structure for table prototypeaccounts.z_sold
CREATE TABLE IF NOT EXISTS `z_sold` (
  `id` int(8) unsigned NOT NULL,
  `dt` datetime DEFAULT NULL,
  `amount` decimal(15,2) unsigned DEFAULT NULL,
  `nodebited` decimal(15,3) DEFAULT NULL,
  `pershare` double DEFAULT NULL,
  `type` int(8) unsigned DEFAULT NULL,
  `fx` decimal(7,4) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.z_sold: ~0 rows (approximately)
/*!40000 ALTER TABLE `z_sold` DISABLE KEYS */;
/*!40000 ALTER TABLE `z_sold` ENABLE KEYS */;

-- Dumping structure for procedure prototypeaccounts.~autoreverseaccruals
DELIMITER //
CREATE PROCEDURE `~autoreverseaccruals`(IN `dt` date, IN `accvar` int(8) unsigned, IN `seg` int(8) unsigned)
    MODIFIES SQL DATA
begin
start transaction;
insert into cashbook1 (date,amount,cat,fullcat,details,creditfk,debitfk,segmentcredit,segmentdebit,segment,fx,status)

select dt,amount,cat,fullcat,concat(details,' CashID:',cashid,', Credit: ',credit,', Debit: ',debit),
accvar,creditfk,seg,debitsegment,segment,fx,status,'A'


 from cashbook1 

inner join
(select cashid from joinedcashbook2 where autoreverse='R' and credit_window='25000' and creditsegment=seg) as t1
using(cashid);

update cashbook1 f 
join 
accounts s on s.accountid=creditfk
join 
accounttypes t on s.AccountFK=t.accountfk
set autoreverse='r',
details=concat(details,'Autoreversed accrual. ',details,', Cat: ',cat,', Fullcat: ',fullcat,', Segmentcredit: ',
segmentcredit,' Segmentdebit: ',segmentdebit),cat=null,fullcat=null,segmentdebit=null,segmentcredit=null
where t.window=25000 and f.autoreverse='R' and coalesce(f.segmentcredit,defaultsegment)=seg;

insert into cashbook1 (date,amount,cat,fullcat,details,creditfk,debitfk,segmentcredit,segmentdebit,segment,fx,status)

select dt,amount,cat,fullcat,concat(details,' CashID:',cashid,', Credit: ',credit,', Debit: ',debit),
debitfk,accvar,creditsegment,seg,segment,fx,status,'A'

 from cashbook1 

inner join
(select cashid from joinedcashbook2 where autoreverse='R' and debit_window='25000' and debitsegment=seg) as t1
using(cashid);

update cashbook1 f 
join 
accounts s on s.accountid=debitfk
join 
accounttypes t on s.AccountFK=t.accountfk
set autoreverse='r',
details=concat(details,'Autoreversed deferral. ',details,', Cat: ',cat,', Fullcat: ',fullcat,', Segmentcredit: ',
segmentcredit,' Segmentdebit: ',segmentdebit),cat=null,fullcat=null,segmentdebit=null,segmentcredit=null
where t.window=25000 and f.autoreverse='R' and coalesce(f.segmentdebit,defaultsegment)=seg;

commit;
end//
DELIMITER ;

-- Dumping structure for view prototypeaccounts.~catbymonth
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `~catbymonth` (
	`year` INT(4) NULL,
	`month` INT(2) NULL,
	`total` DECIMAL(37,2) NULL
) ENGINE=MyISAM;

-- Dumping structure for view prototypeaccounts.~catbyweek
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `~catbyweek` (
	`year` INT(4) NULL,
	`week` INT(2) NULL,
	`total` DECIMAL(37,2) NULL
) ENGINE=MyISAM;

-- Dumping structure for table prototypeaccounts.~old_copy_z_pl
CREATE TABLE IF NOT EXISTS `~old_copy_z_pl` (
  `id` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `dt` datetime DEFAULT NULL,
  `nosold` decimal(15,3) DEFAULT NULL,
  `PL` decimal(15,2) DEFAULT NULL,
  `accountid` int(8) unsigned DEFAULT NULL,
  `type` int(8) unsigned DEFAULT NULL,
  `PL_origin` decimal(15,2) DEFAULT NULL,
  `soldfx` decimal(7,4) unsigned DEFAULT NULL,
  `boughtfx` decimal(7,4) unsigned DEFAULT NULL,
  `boughtdate` datetime DEFAULT NULL,
  `soldunitprice` double DEFAULT NULL,
  `boughtunitprice` double DEFAULT NULL,
  `soldid` int(8) unsigned DEFAULT NULL,
  `boughtid` int(8) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- Dumping data for table prototypeaccounts.~old_copy_z_pl: ~0 rows (approximately)
/*!40000 ALTER TABLE `~old_copy_z_pl` DISABLE KEYS */;
/*!40000 ALTER TABLE `~old_copy_z_pl` ENABLE KEYS */;

-- Dumping structure for procedure prototypeaccounts.~pivotcat
DELIMITER //
CREATE PROCEDURE `~pivotcat`(IN `datestart` date, IN `datefinish` date)
begin
select catdesc, sum(amount) from cashbook1 
inner join catnames
on cat=catno
where ((date>=datestart) and (date<=datefinish) and (cat>0) and (cat<20))
group by cat having sum(amount)>0;

                                                    
end//
DELIMITER ;

-- Dumping structure for view prototypeaccounts.accountsjoined
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `accountsjoined`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `accountsjoined` AS select `accounts`.`AccountFK` AS `AccountFK`,`accounts`.`AccountID` AS `accountID`,`accounts`.`AccountName` AS `AccountName`,`accounts`.`DefaultSegment` AS `DefaultSegment`,`accounts`.`bloomberg` AS `bloomberg`,`accounts`.`epic` AS `epic`,`accounts`.`currency` AS `currency`,`accounts`.`Taxcountry` AS `taxcountry`,`consolidations`.`AccountTypesName` AS `AccountTypesName`,`consolidations`.`Window` AS `window`,`consolidations`.`AccountClass` AS `accountclass`,`consolidations`.`nostro` AS `nostro`,`consolidations`.`balancesheet` AS `balancesheet`,`consolidations`.`asset` AS `asset`,`consolidations`.`income` AS `income`,`consolidations`.`matched` AS `matched`,`segmentsjoined`.`SegmentName` AS `DefaultSegName`,`segmentsjoined`.`SegmentGroupsID` AS `DefaultSegGrpID`,`segmentsjoined`.`SegmentGroup` AS `DefaultSegGrp` from ((`accounts` join `consolidations` on((`accounts`.`AccountFK` = `consolidations`.`AccountFK`))) left join `segmentsjoined` on((`accounts`.`DefaultSegment` = `segmentsjoined`.`SegmentID`))) ;

-- Dumping structure for view prototypeaccounts.balances
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `balances`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `balances` AS select `accountsjoined`.`accountID` AS `accountid`,`accountsjoined`.`AccountName` AS `accountname`,`balancefn`(`accountsjoined`.`accountID`,now()) AS `balance`,`accountsjoined`.`AccountTypesName` AS `accounttypesname`,`accountsjoined`.`AccountFK` AS `accounttypesid` from `accountsjoined` order by `balancefn`(`accountsjoined`.`accountID`,now()) ;

-- Dumping structure for view prototypeaccounts.consolidations
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `consolidations`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `consolidations` AS select `accountclass`.`Window` AS `Window`,`accountclass`.`AccountClass` AS `AccountClass`,`accountclass`.`nostro` AS `nostro`,`accountclass`.`balancesheet` AS `balancesheet`,`accountclass`.`asset` AS `asset`,`accountclass`.`income` AS `income`,`accountclass`.`matched` AS `matched`,`accounttypes`.`AccountFK` AS `AccountFK`,`accounttypes`.`AccountTypesName` AS `AccountTypesName` from (`accountclass` left join `accounttypes` on((`accountclass`.`Window` = `accounttypes`.`Window`))) ;

-- Dumping structure for view prototypeaccounts.excelshares
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `excelshares`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `excelshares` AS select `accounts`.`AccountID` AS `accountid`,`accounts`.`AccountName` AS `Company`,`sharebalfn`(`accounts`.`AccountID`,cast(now() as date)) AS `Holding`,`balancefn`(`accounts`.`AccountID`,cast(now() as date)) AS `Book Value`,`accounts`.`bloomberg` AS `bloomberg` from `accounts` where (`accounts`.`AccountFK` = 5) order by `sharebalfn`(`accounts`.`AccountID`,cast(now() as date)) desc ;

-- Dumping structure for view prototypeaccounts.joinedcashbook
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `joinedcashbook`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `joinedcashbook` AS select `cashbook1`.`cashID` AS `cashid`,`cashbook1`.`Date` AS `date`,`cashbook1`.`Amount` AS `amount`,`cashbook1`.`Cat` AS `cat`,`catnames`.`CatDesc` AS `catdesc`,`cashbook1`.`FullCat` AS `fullcat`,`cashbook1`.`creditFK` AS `creditfk`,`cred`.`AccountName` AS `credit`,`cred`.`AccountTypesName` AS `credit_type`,`cred`.`AccountFK` AS `credit_type_FK`,`cred`.`currency` AS `credit_currency`,`cashbook1`.`DebitFK` AS `debitfk`,`deb`.`AccountName` AS `debit`,`deb`.`AccountTypesName` AS `debit_type`,`deb`.`AccountFK` AS `debit_type_FK`,`deb`.`currency` AS `debit_currency`,`cashbook1`.`Details` AS `details`,`cashbook1`.`segment` AS `segment`,`segments`.`SegmentName` AS `segmentname`,`cashbook1`.`segmentcredit` AS `segmentfk`,`cashbook1`.`cheque` AS `cheque`,`cashbook1`.`transactiontime` AS `transactiontime`,`cashbook1`.`Numbercredited` AS `numbercredited`,`cashbook1`.`Numberdebited` AS `numberdebited`,`cashbook1`.`commission` AS `commission`,`cashbook1`.`fx` AS `fx`,`cashbook1`.`tstamp` AS `tstamp` from ((((`accountsjoined` `deb` join `cashbook1` on((`cashbook1`.`DebitFK` = `deb`.`accountID`))) join `accountsjoined` `cred` on((`cashbook1`.`creditFK` = `cred`.`accountID`))) left join `catnames` on((`cashbook1`.`Cat` = `catnames`.`CatNo`))) left join `segments` on((`cashbook1`.`segmentcredit` = `segments`.`SegmentID`))) order by `cashbook1`.`tstamp` desc ;

-- Dumping structure for view prototypeaccounts.joinedcashbook2
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `joinedcashbook2`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `joinedcashbook2` AS select `prelimjoinedcashbook`.`cashid` AS `cashid`,`prelimjoinedcashbook`.`date` AS `date`,`prelimjoinedcashbook`.`amount` AS `amount`,`prelimjoinedcashbook`.`cat` AS `cat`,`prelimjoinedcashbook`.`fullcat` AS `fullcat`,`prelimjoinedcashbook`.`catdesc` AS `catdesc`,`prelimjoinedcashbook`.`credit` AS `credit`,`prelimjoinedcashbook`.`debit` AS `debit`,`prelimjoinedcashbook`.`details` AS `details`,`prelimjoinedcashbook`.`creditfk` AS `creditfk`,`prelimjoinedcashbook`.`debitfk` AS `debitfk`,`prelimjoinedcashbook`.`creditsegment` AS `creditsegment`,`cr`.`SegmentName` AS `Credit_SegName`,`cr`.`SegmentGroupsID` AS `Credit_SegGrpID`,`cr`.`SegmentGroup` AS `Credit_SegGrp`,`prelimjoinedcashbook`.`debitsegment` AS `debitsegment`,`de`.`SegmentName` AS `Debit_SegName`,`de`.`SegmentGroupsID` AS `Debit_SegGrpID`,`de`.`SegmentGroup` AS `Debit_SegGrp`,`prelimjoinedcashbook`.`cheque` AS `cheque`,`prelimjoinedcashbook`.`transactiontime` AS `transactiontime`,`prelimjoinedcashbook`.`numbercredited` AS `numbercredited`,`prelimjoinedcashbook`.`numberdebited` AS `numberdebited`,`prelimjoinedcashbook`.`commission` AS `commission`,`prelimjoinedcashbook`.`fx` AS `fx`,`prelimjoinedcashbook`.`status` AS `status`,`prelimjoinedcashbook`.`autoreverse` AS `autoreverse`,`prelimjoinedcashbook`.`credit_Type_FK` AS `credit_Type_FK`,`prelimjoinedcashbook`.`credit_window` AS `credit_window`,`prelimjoinedcashbook`.`credit_currency` AS `credit_currency`,`prelimjoinedcashbook`.`credit_taxcountry` AS `credit_taxcountry`,`prelimjoinedcashbook`.`credit_type` AS `credit_type`,`prelimjoinedcashbook`.`credit_nostro` AS `credit_nostro`,`prelimjoinedcashbook`.`credit_balancesheet` AS `credit_balancesheet`,`prelimjoinedcashbook`.`credit_asset` AS `credit_asset`,`prelimjoinedcashbook`.`credit_income` AS `credit_income`,`prelimjoinedcashbook`.`credit_matched` AS `credit_matched`,`prelimjoinedcashbook`.`debit_Type_FK` AS `debit_Type_FK`,`prelimjoinedcashbook`.`debit_window` AS `debit_window`,`prelimjoinedcashbook`.`debit_currency` AS `debit_currency`,`prelimjoinedcashbook`.`debit_taxcountry` AS `debit_taxcountry`,`prelimjoinedcashbook`.`debit_type` AS `debit_type`,`prelimjoinedcashbook`.`debit_nostro` AS `debit_nostro`,`prelimjoinedcashbook`.`debit_balancesheet` AS `debit_balancesheet`,`prelimjoinedcashbook`.`debit_asset` AS `debit_asset`,`prelimjoinedcashbook`.`debit_income` AS `debit_income`,`prelimjoinedcashbook`.`debit_matched` AS `debit_matched` from ((`prelimjoinedcashbook` left join `segmentsjoined` `cr` on((`prelimjoinedcashbook`.`creditsegment` = `cr`.`SegmentID`))) left join `segmentsjoined` `de` on((`prelimjoinedcashbook`.`debitsegment` = `de`.`SegmentID`))) order by `prelimjoinedcashbook`.`cashid` ;

-- Dumping structure for view prototypeaccounts.prelimjoinedcashbook
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `prelimjoinedcashbook`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `prelimjoinedcashbook` AS select `cashbook1`.`cashID` AS `cashid`,`cashbook1`.`Date` AS `date`,`cashbook1`.`Amount` AS `amount`,`cashbook1`.`Cat` AS `cat`,`cashbook1`.`FullCat` AS `fullcat`,`catnames`.`CatDesc` AS `catdesc`,`cr`.`AccountName` AS `credit`,`de`.`AccountName` AS `debit`,`cashbook1`.`Details` AS `details`,`cashbook1`.`creditFK` AS `creditfk`,`cashbook1`.`DebitFK` AS `debitfk`,coalesce(`cashbook1`.`segmentcredit`,`cr`.`DefaultSegment`) AS `creditsegment`,coalesce(`cashbook1`.`segmentdebit`,`de`.`DefaultSegment`) AS `debitsegment`,`cashbook1`.`cheque` AS `cheque`,`cashbook1`.`transactiontime` AS `transactiontime`,`cashbook1`.`Numbercredited` AS `numbercredited`,`cashbook1`.`Numberdebited` AS `numberdebited`,`cashbook1`.`commission` AS `commission`,`cashbook1`.`fx` AS `fx`,`cashbook1`.`Status` AS `status`,`cashbook1`.`Autoreverse` AS `autoreverse`,`cr`.`AccountFK` AS `credit_Type_FK`,`cr`.`window` AS `credit_window`,`cr`.`currency` AS `credit_currency`,`cr`.`taxcountry` AS `credit_taxcountry`,`cr`.`AccountTypesName` AS `credit_type`,`cr`.`nostro` AS `credit_nostro`,`cr`.`balancesheet` AS `credit_balancesheet`,`cr`.`asset` AS `credit_asset`,`cr`.`income` AS `credit_income`,`cr`.`matched` AS `credit_matched`,`de`.`AccountFK` AS `debit_Type_FK`,`de`.`window` AS `debit_window`,`de`.`currency` AS `debit_currency`,`de`.`taxcountry` AS `debit_taxcountry`,`de`.`AccountTypesName` AS `debit_type`,`de`.`nostro` AS `debit_nostro`,`de`.`balancesheet` AS `debit_balancesheet`,`de`.`asset` AS `debit_asset`,`de`.`income` AS `debit_income`,`de`.`matched` AS `debit_matched` from (((`cashbook1` join `accountsjoined` `cr` on((`cashbook1`.`creditFK` = `cr`.`accountID`))) join `accountsjoined` `de` on((`cashbook1`.`DebitFK` = `de`.`accountID`))) left join `catnames` on((`catnames`.`CatNo` = `cashbook1`.`Cat`))) ;

-- Dumping structure for view prototypeaccounts.segmentsjoined
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `segmentsjoined`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `segmentsjoined` AS select `segments`.`SegmentGroupsID` AS `SegmentGroupsID`,`segments`.`SegmentID` AS `SegmentID`,`segments`.`SegmentName` AS `SegmentName`,`segmentgroups`.`SegmentGroup` AS `SegmentGroup` from (`segments` join `segmentgroups` on((`segments`.`SegmentGroupsID` = `segmentgroups`.`SegmentGroupsID`))) ;

-- Dumping structure for view prototypeaccounts.sharebalances
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `sharebalances`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `sharebalances` AS select `accountsjoined`.`DefaultSegName` AS `companyname`,`balancefn`(`accountsjoined`.`accountID`,curdate()) AS `BookValue`,`accountsjoined`.`accountID` AS `accountid`,`accountsjoined`.`epic` AS `epic`,`accountsjoined`.`AccountName` AS `accountname`,`sharebalfn`(`accountsjoined`.`accountID`,curdate()) AS `Holding` from `accountsjoined` where (`accountsjoined`.`AccountFK` = 5) order by `accountsjoined`.`DefaultSegName` ;

-- Dumping structure for view prototypeaccounts.z_pljoined
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `z_pljoined`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `z_pljoined` AS select `z_pl`.`accountid` AS `accountid`,`z_pl`.`id` AS `id`,`z_pl`.`dt` AS `dt`,`z_pl`.`nosold` AS `nosold`,`z_pl`.`PL` AS `PL`,`z_pl`.`type` AS `type`,`z_pl`.`PL_origin` AS `PL_origin`,`z_pl`.`soldfx` AS `soldfx`,`z_pl`.`boughtfx` AS `boughtfx`,`z_pl`.`boughtdate` AS `boughtdate`,`z_pl`.`soldunitprice` AS `soldunitprice`,`z_pl`.`boughtunitprice` AS `boughtunitprice`,`z_pl`.`soldid` AS `soldid`,`z_pl`.`boughtid` AS `boughtid`,`accounts`.`AccountName` AS `AccountName`,`accounts`.`AccountFK` AS `AccountFK`,`accounts`.`DefaultSegment` AS `DefaultSegment`,`accounts`.`bloomberg` AS `bloomberg`,`accounts`.`epic` AS `epic`,`accounts`.`tstampaccounts` AS `tstampaccounts`,`accounts`.`currency` AS `currency`,`accounts`.`Taxcountry` AS `Taxcountry`,(`z_pl`.`PL_origin` / `z_pl`.`soldfx`) AS `primary_pl`,(`z_pl`.`PL` - (`z_pl`.`PL_origin` / `z_pl`.`soldfx`)) AS `fx_pl` from (`z_pl` join `accounts` on((`z_pl`.`accountid` = `accounts`.`AccountID`))) order by `z_pl`.`dt` ;

-- Dumping structure for view prototypeaccounts.~catbymonth
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `~catbymonth`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `~catbymonth` AS select year(`cashbook1`.`Date`) AS `year`,month(`cashbook1`.`Date`) AS `month`,sum(`cashbook1`.`Amount`) AS `total` from `cashbook1` where ((`cashbook1`.`Cat` > 0) and (`cashbook1`.`Cat` < 20)) group by year(`cashbook1`.`Date`),month(`cashbook1`.`Date`);

-- Dumping structure for view prototypeaccounts.~catbyweek
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `~catbyweek`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `~catbyweek` AS select year(`cashbook1`.`Date`) AS `year`,week(`cashbook1`.`Date`,0) AS `week`,sum(`cashbook1`.`Amount`) AS `total` from `cashbook1` where ((`cashbook1`.`Cat` > 0) and (`cashbook1`.`Cat` < 20)) group by year(`cashbook1`.`Date`),week(`cashbook1`.`Date`,0);

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
