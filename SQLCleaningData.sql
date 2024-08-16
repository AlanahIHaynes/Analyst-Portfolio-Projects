-- Populate Property Address for Nulls
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isNull(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
JOIN NashvilleHousingData b
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
JOIN NashvilleHousingData b
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


-- Breaking Property Address into 2 Components

SELECT 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add PropertySplitCity nvarchar(255);

ALTER TABLE NashvilleHousingData
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousingData
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update NashvilleHousingData
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
from NashvilleHousingData


-- Breaking Owner Address into components

Select OwnerAddress
From NashvilleHousingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress nvarchar(255);

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity nvarchar(255);

ALTER TABLE NashvilleHousingData
Add OwnerSplitState nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT * 
From NashvilleHousingData

-- Change Sold as Vacant Field to Consistent Yes and No

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousingData
Group by SoldAsVacant
Order by 2


SELECT SoldAsVacant, 
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END
From NashvilleHousingData

Update NashvilleHousingData
Set SoldAsVacant = 
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END

-- Remove Duplicates

SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, 
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    ORDER by 
                    UniqueID
    ) row_num
From NashvilleHousingData
order by ParcelID

WITH RowNumCTE AS(
    SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, 
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    ORDER by 
                    UniqueID
    ) row_num
From NashvilleHousingData
)



-- DELETE
-- From RowNumCTE
-- Where row_num > 1

SELECT *
From RowNumCTE
Where row_num > 1


--Deleting Unused Columns

Select *
From NashvilleHousingData

ALTER TABLE NashvilleHousingData
DROP COLUMN OwnerAddress, PropertyAddress