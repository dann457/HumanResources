SELECT * FROM NashvilleHousing..NashvilleHousing;
/* Cleaning Data in SQL Queries */

--Standardize Date Format
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing..NashvilleHousing;

UPDATE NashvilleHousing..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

-- Populate Property Address data
SELECT *
FROM NashvilleHousing..NashvilleHousing
WHERE PropertyAddress IS NULL;

SELECT n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress, ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM NashvilleHousing..NashvilleHousing n1 JOIN NashvilleHousing..NashvilleHousing n2
	ON n1.ParcelID = n2.ParcelID
		AND n1.[UniqueID ] <> n2.[UniqueID ]
WHERE n1.PropertyAddress IS NULL;

UPDATE n1
SET PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM NashvilleHousing..NashvilleHousing n1 JOIN NashvilleHousing..NashvilleHousing n2
	ON n1.ParcelID = n2.ParcelID
		AND n1.[UniqueID ] <> n2.[UniqueID ]
WHERE n1.PropertyAddress IS NULL;

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM NashvilleHousing..NashvilleHousing;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySlitAddress NVARCHAR(255);

UPDATE NashvilleHousing..NashvilleHousing
SET PropertySlitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
ADD PropertySlitCity NVARCHAR(255);

UPDATE NashvilleHousing..NashvilleHousing
SET PropertySlitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT OwnerAddress 
FROM NashvilleHousing..NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSlitAddress NVARCHAR(255);

UPDATE NashvilleHousing..NashvilleHousing
SET OwnerSlitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
ADD OwnerSlitCity NVARCHAR(255);

UPDATE NashvilleHousing..NashvilleHousing
SET OwnerSlitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
ADD OwnerSlitState NVARCHAR(255);

UPDATE NashvilleHousing..NashvilleHousing
SET OwnerSlitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

--Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant, COUNT(*)
FROM NashvilleHousing..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing..NashvilleHousing;

UPDATE NashvilleHousing..NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END;

-- Remove Duplicates

WITH RowNumCTE AS
(SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
						ORDER BY UniqueID) row_num
FROM NashvilleHousing..NashvilleHousing)

DELETE 
FROM RowNumCTE
WHERE row_num > 1;

--Delete Unused Columns

ALTER TABLE NashvilleHousing..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE NashvilleHousing..NashvilleHousing
DROP COLUMN SaleDate;