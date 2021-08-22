SELECT * 
FROM DataCleaningProject.dbo.NashvilleHousing


---------------------------------------------------------------
-- Standardise date format

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM DataCleaningProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


---------------------------------------------------------------

--Populate property address data

SELECT * 
FROM DataCleaningProject.dbo.NashvilleHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleHousing a
JOIN DataCleaningProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleHousing a
JOIN DataCleaningProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]



---------------------------------------------------------------

-- Breaking out address into individual columns (address, city, state)

SELECT PropertyAddress
FROM DataCleaningProject.dbo.NashvilleHousing
-- WHERE PropertyAddress is null
-- ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address

FROM DataCleaningProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);


Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);


Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 



SELECT OwnerAddress
FROM DataCleaningProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM DataCleaningProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);


Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
 

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
 







---------------------------------------------------------------

-- Changin Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END  
FROM DataCleaningProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END  



---------------------------------------------------------------

-- Removing duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
						ORDER BY
						UniqueID) row_num



FROM DataCleaningProject.dbo.NashvilleHousing
)
Select * 
FROM RowNumCTE
WHERE row_num > 1




---------------------------------------------------------------

-- Removing unused columns


SELECT * 
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
DROP COLUMN SaleDate