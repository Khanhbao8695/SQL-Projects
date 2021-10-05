
---------------------------------------------------------------------------------------------------------
-- Explore Dataset
select *
from PorfolioProject..NashvileHousing
---------------------------------------------------------------------------------------------------------

-- Cleaning dataset

--Standardize Date Format
select SaleDateConverted, convert(Date,SaleDate)
from PorfolioProject..NashvileHousing

alter table NashvileHousing
Add SaleDateConverted Date;

update NashvileHousing
set SaleDateConverted = convert(Date,SaleDate)
---------------------------------------------------------------------------------------------------------

-- Property Address
-- Update missing information in Property Address with self-join
-- isnull (if a is null, we use b)
select a.PropertyAddress,a.ParcelID, b.PropertyAddress, b.ParcelID, isnull(a.PropertyAddress, b.PropertyAddress)
from PorfolioProject..NashvileHousing a
join PorfolioProject..NashvileHousing b
	on a.ParcelID = b.ParcelID
-- They have different unique ID so just want to join a common ParceID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Update to get immediately effect on the table
Update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PorfolioProject..NashvileHousing a
join PorfolioProject..NashvileHousing b
	on a.ParcelID = b.ParcelID
-- They have different unique ID so just want to join a common ParceID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- After running update and re check the property address, there is no more missing value
---------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual columns (Address, City, State)

select *
from PorfolioProject..NashvileHousing

-- Substring method
select 
-- use -1 to return no ","
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
-- use first line to continue filter out the city
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
from PorfolioProject..NashvileHousing

-- Parsename also works in this case and faster
select 
PARSENAME(replace(PropertyAddress, ',','.'), 1) as City,
PARSENAME(replace(PropertyAddress, ',','.'), 2) as Address
from PorfolioProject..NashvileHousing

alter table NashvileHousing 
Add 
	PropertySplitAddress Nvarchar(255),
	PropertySplitCity Nvarchar(255)

update NashvileHousing
Set 
	PropertySplitCity = PARSENAME(replace(PropertyAddress, ',','.'), 1),
	PropertySplitAddress = PARSENAME(replace(PropertyAddress, ',','.'), 2)

-- Owner address
select 
PARSENAME(replace(OwnerAddress, ',','.'), 3) as Address,
PARSENAME(replace(OwnerAddress, ',','.'), 2) as City,
PARSENAME(replace(OwnerAddress, ',','.'), 1) as State
from PorfolioProject..NashvileHousing

alter table NashvileHousing 
Add 
	OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255)

update NashvileHousing
Set 
	OwnerSplitState = PARSENAME(replace(OwnerAddress, ',','.'), 1),
	OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',','.'), 2),
	OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',','.'), 3)
---------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold As Vacant" column
select Distinct(SoldAsVacant), count(SoldAsVacant)
from PorfolioProject..NashvileHousing
group by (SoldAsVacant)
order by 2

-- Change Y & N to Yes and No with Case function

select SoldAsVacant,
	Case When SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from PorfolioProject..NashvileHousing

Update NashvileHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
---------------------------------------------------------------------------------------------------------

-- Remove Duplicate Value


With RowNumCTE As(
Select *, ROW_NUMBER () Over (
								Partition By ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
								order by UniqueID) row_num
from PorfolioProject..NashvileHousing
)

Delete
from RowNumCTE
where row_num >1
--order by PropertyAddress

-- Checking
Select *
from PorfolioProject..NashvileHousing
---------------------------------------------------------------------------------------------------------

-- Remove unused columns 
Select *
From PorfolioProject..NashvileHousing

ALTER TABLE PorfolioProject..NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate