SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------
-- Standardise the date format 

SELECT SaleDate
		,CAST(SaleDate as date) as SaleDate
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CAST(SaleDate as date)

ALTER TABLE NashvilleHousing
add SaleDateUpdated date;

UPDATE NashvilleHousing
SET SaleDateUpdated = CAST(SaleDate as date)

----------------------------------------------------------------------------------
-- Populate property Address data and fill NULL values based on ParcelID where available

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is NULL

SELECT n.ParcelID
	, n.PropertyAddress	
	, n2.ParcelID 
	, n2.PropertyAddress	
	, ISNULL(n.PropertyAddress, n2.PropertyAddress) AS PropertyAddressUpdated
FROM PortfolioProject.dbo.NashvilleHousing n
INNER JOIN PortfolioProject.dbo.NashvilleHousing n2
	ON n.ParcelID = n2.ParcelID
	AND n.[UniqueID ] <> n2.[UniqueID ]
WHERE n.PropertyAddress is NULL


UPDATE n
SET PropertyAddress = ISNULL(n.PropertyAddress, n2.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing n
INNER JOIN PortfolioProject.dbo.NashvilleHousing n2
	ON n.ParcelID = n2.ParcelID
	AND n.[UniqueID ] <> n2.[UniqueID ]
WHERE n.PropertyAddress is NULL


-------------------------------------------------------
-- Breaking out Address in to multiple columns

SELECT PropertyAddress
	,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address
	,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) As city
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255); 

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-----------------------------------------------------------
-- Breaking it out OwnerAddress in to three 

SELECT OwnerAddress,
,PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS OwnerStreet 
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS OwnerCity  
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS OwnerState
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerStreet NVARCHAR(255),
OwnerCity NVARCHAR(255),
OwnerState NVARCHAR(10)

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3), 
OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2), 
OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes & No in " Sold as vacant" field 

Select  SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END 
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =  
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END 
	FROM PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------

-- Removing duplicate data

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice,SaleDate,LegalReference ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE  
FROM RowNumCTE
WHERE row_num = 2


----------------------------------------------------------------


