--Cleaning Data in SQL Queries

SELECT * FROM NashvilleHousing

----Change Date Format

SELECT SaleDate, SaleDateConverted
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

----Populate Property Address Data
----RENAME orig & dupe

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

----Test Results
SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL


----Breaking Address up into Individual Columns (Address, City, State)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City

FROM NashvilleHousing
 ------Commit changes

ALTER TABLE NashvilleHousing
ADD PropertyAdd nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAdd = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT * FROM NashvilleHousing

----Owner Address

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM NashvilleHousing

------Commit Changes

ALTER TABLE NashvilleHousing
ADD OwnerAdd nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerCity nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerAdd = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

----Change Y and N to Yes and No in 'Sold as Vacant'

SELECT DISTINCT(SoldasVacant), COUNT(SoldasVacant)
FROM NashvilleHousing
GROUP BY SoldasVacant
ORDER BY 2

SELECT SoldasVacant,
CASE
	WHEN SoldasVacant = 'Y' THEN 'Yes'
	WHEN SoldasVacant = 'N' THEN 'No'
	ELSE SoldasVacant
END
FROM NashvilleHousing

ORDER BY SoldAsVacant

------Commit changes

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldasVacant = 'Y' THEN 'Yes'
	WHEN SoldasVacant = 'N' THEN 'No'
	ELSE SoldasVacant
END

----Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelId,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
					 UniqueId
					 ) row_num

FROM NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1

----Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

SELECT * FROM NashvilleHousing



