create procedure al
AS
select *
from ..NashvilleHousing
GO
--- Standardize Sale Date ---

select SaleDate, CONVERT(Date, SaleDate)
from ..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

Alter table NashvilleHousing
Add SaleDate2 Date;

update NashvilleHousing
set SaleDate2 = CONVERT(Date, SaleDate)


--- Populate property address ---

exec al

select *
from ..NashvilleHousing
where PropertyAddress is null

select na1.[UniqueID ], na1.ParcelID, na1.PropertyAddress, na2.[UniqueID ], na2.ParcelID, na2.PropertyAddress,
ISNULL(na1.PropertyAddress,na2.PropertyAddress) as Populated_column
from ..NashvilleHousing as na1
join ..NashvilleHousing as na2
on na1.ParcelID=na2.ParcelID and na1.[UniqueID ] != na2.[UniqueID ]
where na1.PropertyAddress is null											---- used self join

update na1
set PropertyAddress = ISNULL(na1.PropertyAddress,na2.PropertyAddress)
from ..NashvilleHousing as na1
join ..NashvilleHousing as na2
on na1.ParcelID=na2.ParcelID and na1.[UniqueID ] != na2.[UniqueID ]
where na1.PropertyAddress is null


--- Breaking address into individual columns ---

exec al

select PropertyAddress
from ..NashvilleHousing

select SUBSTRING( PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Addres,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) as State
from ..NashvilleHousing
--- adding address column
Alter Table NashvilleHousing
Add PropertySlpitAddress varchar(100)

Update NashvilleHousing
set PropertySlpitAddress= SUBSTRING( PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


--- adding state column
Alter table NashvilleHousing
add PropertySlpitState varchar(100)

Update NashvilleHousing
set PropertySlpitState = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))



--- Owner Address ---

select OwnerAddress
from ..NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Postcode,
PARSENAME(Replace(OwnerAddress,',','.'),2) as City,
PARSENAME(Replace(OwnerAddress,',','.'),1) as State
from ..NashvilleHousing

-- adding post code
Alter table NashvilleHousing
add Post_code varchar(200)
update NashvilleHousing
set Post_code = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

--- adding city

Alter table NashvilleHousing
add Owner_City varchar(200)

Update NashvilleHousing
set Owner_City = PARSENAME(Replace(OwnerAddress,',','.'),2)

-- adding state

Alter table NashvilleHousing
add Owner_state varchar(50)

update NashvilleHousing
set Owner_state = PARSENAME(Replace(OwnerAddress,',','.'),1)



---- change y and n to yes and no ---

select distinct(SoldAsVacant)
from ..NashvilleHousing


select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant= 'N' Then 'No'
	else SoldAsVacant
	End
from ..NashvilleHousing

update NashvilleHousing
set SoldAsVacant= case when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant= 'N' Then 'No'
	else SoldAsVacant
	End



-- Remove duplicates --
exec al

WITH rownum as (
select *,
ROW_NUMBER() over (
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueId
) as row_num
from ..NashvilleHousing
)

Delete  from rownum
where row_num > 1



-- Delete unused columns --

exec al

Alter table NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter table NashvilleHousing
DROP COLUMN SaleDate