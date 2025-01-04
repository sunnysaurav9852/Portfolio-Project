/*

Data Cleaning in SQL

*/

select * from [dbo].[NashvilleHousing]


-----------------------------------------------------------------------

-- Standardize Date Format

select SaleDate,CONVERT(DATE,SaleDate)
from [dbo].[NashvilleHousing]

Update [dbo].[NashvilleHousing]
SET SaleDate = CONVERT(DATE,SaleDate)


-------------------------------------------------------------------------
--Populate Property Address data

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b ON a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b ON a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--------------------------------------------------------------------------

---Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress from [dbo].[NashvilleHousing]

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS ADDRESS
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS CITY
FROM
[dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
Add PropertySplitAddress Nvarchar(255);

Update [dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [dbo].[NashvilleHousing]
Add PropertySplitCity Nvarchar(255);

Update [dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select * from [dbo].[NashvilleHousing]

select OwnerAddress
from [dbo].[NashvilleHousing]

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS ADDRESS,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS CITY,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS STATE
from [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update [dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [dbo].[NashvilleHousing]
Add OwnerSplitCity Nvarchar(255);

Update [dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [dbo].[NashvilleHousing]
Add OwnerSplitState Nvarchar(255);

Update [dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * from [dbo].[NashvilleHousing]

-------------------------------------------------------------------------------------

--Change 0 and 1 to Yes and No in "Sold as Vacant" field

ALTER TABLE [dbo].[NashvilleHousing]
ALTER COLUMN SoldAsVacant nvarchar(10);

select distinct SoldAsVacant from [dbo].[NashvilleHousing]

Update [dbo].[NashvilleHousing]
SET SoldAsVacant = 'Yes'
where SoldAsVacant = '1'

Update [dbo].[NashvilleHousing]
SET SoldAsVacant = 'No'
where SoldAsVacant = '0'

-----------------------------------------------------------------------------------------

--Remove Duplicates
With RowNumCTE AS(
select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			 UniqueID) row_num
FROM
[dbo].[NashvilleHousing]
)

delete from RowNumCTE where row_num > 1


-------------------------------------------------------------------------------------------

--Delete Unused  Columns

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress


select * from [dbo].[NashvilleHousing]