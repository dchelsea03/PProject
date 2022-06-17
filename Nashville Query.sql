SELECT * 
FROM PortfolioProject..NashvilleData

--Standardize Sale Date
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleData

UPDATE PortfolioProject..NashvilleData
SET SaleDate=CONVERT(Date,SaleDate)

SELECT SaleDate
FROM PortfolioProject..NashvilleData

--Fill in Null Property Address

--Check null values
SELECT PropertyAddress
FROM PortfolioProject..NashvilleData
WHERE PropertyAddress is null

--Note: the same ParcelID the same Property Address
SELECT * 
FROM PortfolioProject..NashvilleData
ORDER BY ParcelID

--Join tables where parcel id is the same but not in the same row and populate null ProperyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleData a
JOIN PortfolioProject..NashvilleData b
	ON a.ParcelID=B.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleData a
JOIN PortfolioProject..NashvilleData b
	ON a.ParcelID=B.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null


--Break Address into different columns (Address, City, State)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleData

ALTER TABLE PortfolioProject..NashvilleData
Add PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleData
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleData
Add PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleData
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


--Break Address into different columns (Address,City,State)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleData

ALTER TABLE PortfolioProject..NashvilleData
Add PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleData
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleData
Add PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleData
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--Splitting OWNER ADDRESS using PARSENAME
SELECT OwnerAddress
FROM PortfolioProject..NashvilleData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
FROM PortfolioProject..NashvilleData

/*ALTER TABLE PortfolioProject..NashvilleData
DROP COLUMN OwnerAddress;*/

ALTER TABLE PortfolioProject..NashvilleData
Add OwnerStAdd NVARCHAR(255),
OwnerCity NVARCHAR(255),
OwnerState NVARCHAR(255);

UPDATE PortfolioProject..NashvilleData
SET OwnerStAdd=PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
OwnerCity=PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
OwnerState=PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


--Format SoldAsVacant column to 'Yes' and 'No' only
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacanT
	 END
FROM PortfolioProject..NashvilleData

UPDATE PortfolioProject..NashvilleData
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacanT
	 END

--Handle Duplicates by removing them
WITH rowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				) rowNum
FROM PortfolioProject..NashvilleData
)
DELETE
FROM rowNumCTE
WHERE rowNum>1

--Removed unused columns
ALTER TABLE PortfolioProject..NashvilleData
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

