/* cleaning of data*/


/* STEP 1 STANDARDIZE DATE FORMAT */

ALTER TABLE housing_data
ADD column SaleDate2 date;

UPDATE housing_data SET SaleDate2  = CAST(saledate as date) WHERE saledate LIKE'%2%';
commit;

select *
from housing_data;
/* STEP 2 POPULATE THE PROPERTY ADDRESS DATA*/

select *
from housing_data 
where PropertyAddress Is null;

select *
from housing_data
order by ParcelID; 

-- self join
select h1.parcelid,h1.PropertyAddress,h2.ParcelID,h2.PropertyAddress,Ifnull(h1.PropertyAddress, h2.propertyaddress) AS PropertyAddress
from housing_data h1
join housing_data h2 on h1.parcelid=h2.parcelid and h1.uniqueid <> h2.uniqueid
where h1.PropertyAddress is null;

Update housing_data h1 
join housing_data h2 on h1.parcelid=h2.parcelid and h1.uniqueid <> h2.uniqueid
set h1.PropertyAddress = Ifnull(h1.PropertyAddress, h2.propertyaddress)
where h1.PropertyAddress is null;

commit;
select PropertyAddress
from housing_data;

/* STEP 3 BREAKING THE ADDRSS INTO INDIVIDUAL COLUMNS( ADDRESS,CITY,STATE) */
select 
SUBSTRING_INDEX(PropertyAddress,',',1) AS Address,
SUBSTRING_INDEX(PropertyAddress,',',-1) as City
from housing_data;

ALTER TABLE housing_data
ADD column Address varchar(255);

Update housing_data set Address=SUBSTRING_INDEX(PropertyAddress,',',1);
commit;
ALTER TABLE housing_data
ADD column City varchar(255);

Update housing_data set City= SUBSTRING_INDEX(PropertyAddress,',',-1) ;
commit;

select *
from housing_data;

select OwnerAddress
from housing_data;

select
SUBSTRING_INDEX(OwnerAddress,',',1) as OwnerSplitAddress,
substring_index(substring_index(OwnerAddress,',',-2),',',1) as OwnerSplitCity,
SUBSTRING_INDEX(OwnerAddress,',',-1) as OwnerSplitSate
from housing_data;


/* STEP4 CHANGE Y TO YES AND N TO NO IN SOLD AS VACANT COLUMN*/

select distinct SoldASVacant, count(SoldAsVacant)
from housing_data
group by SoldAsVacant
order by 2;

SELECT 
   SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 'y' THEN 'Yes'
        WHEN SoldAsVacant = 'n' THEN 'No'
        else SoldAsVacant
	END AS SoldAsVacant
FROM
    housing_data;
    
    Alter table housing_data ADD column SoldAsVacant2 VARCHAR(11);
    
   
    Update  housing_data set
    SoldAsVacant2 = 
    CASE 
        WHEN SoldAsVacant = 'y' THEN 'Yes'
        WHEN SoldAsVacant = 'n' THEN 'No'
        else SoldAsVacant
	END ;
    
    commit;
    
select distinct SoldASVacant2, count(SoldAsVacant2)
from housing_data
group by SoldAsVacant2
order by 2;
	
/* STEP 5 REMOVE DUPLICATE  -- We will do this in excel*/


/* STEP 6 DELETE UNUSED COLUMNS*/
select * 
from housing_data;

alter table housing_data
Drop column ownername,
Drop column PropertyAddress,
Drop column Owneraddress,
Drop column taxdistrict,
Drop column soldasvacant,
Drop column SaleDate;

select * from housing_data;

