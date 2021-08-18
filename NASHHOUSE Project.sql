-- Cleaning Data in SQL
SELECT *
FROM house_nash

-----------------------------------------------------------------
--Standardized sale date

SELECT SaleDate, CONVERT(Date, SaleDate) AS NF_SaleDate
FROM house_nash

UPDATE house_nash
SET SaleDate = CONVERT(Date, SaleDate)

--------------------------------------------------------------------
-- Populate property address, We use isnull because we want to populate the data to the null collumns.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM house_nash a
JOIN house_nash b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM house_nash a
JOIN house_nash b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

----------------------------------------------------------------------------
--Breaking address into individual column

SELECT PropertyAddress
FROM house_nash

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX( ',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX( ',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM house_nash

ALTER TABLE house_nash
Add PropertySplitAddress NVARCHAR(250);
UPDATE house_nash
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX( ',', PropertyAddress)-1)

ALTER TABLE house_nash
Add PropertySplitCity NVARCHAR(250);
UPDATE house_nash
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX( ',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
FROM house_nash

ALTER TABLE house_nash
Add OwnerSplitAddress NVARCHAR(250);
UPDATE house_nash
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)

ALTER TABLE house_nash
Add OwnerSplitCity NVARCHAR(250);
UPDATE house_nash
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)

ALTER TABLE house_nash
Add OwnerSplitState NVARCHAR(250);
UPDATE house_nash
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)

--Change n/y to yes/no--------------------------------------------------------------
SELECT SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant 
		END
FROM house_nash

UPDATE house_nash
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant 
		END

--Remove duplicate--------------------------------------------------------------------------

WITH RowNumCTE AS(
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
			ORDER BY UniqueID
			) row_num
	FROM house_nash
	--ORDER BY ParcelID
	)
--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num>1

-- Delete unused collumns
-- ALTER TABLE house_nash
-- DROP COLLUMN _____,______ collumn name








