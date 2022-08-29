/* 

-- Cleaning Data in SQL Queries
--Using the Database NashvilleHousing from Kaggle

*/

Select * 
From PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate) 
From PortfolioProject.dbo.NashvilleHousing

--Update NashvilleHousing
--SET SaleDate = CONVERT(Date, SaleDate) 

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date --Add a new column

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate) --Update the column with the new date data type

Select *
From PortfolioProject.dbo.NashvilleHousing -- The SaleDateConverted Column has been added


------------------------------------------------------------------------------------------------


-- Populate Property Address Data 
-- Records having the same Parcel ID, have the same Address.

Select *
From PortfolioProject.dbo.NashvilleHousing
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null



--------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing 


Select 
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +2, LEN(PropertyAddress) ) AS City

From PortfolioProject.dbo.NashvilleHousing 



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress varchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) 



ALTER TABLE NashvilleHousing
ADD PropertySplitCity varchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +2, LEN(PropertyAddress) )


Select PropertySplitAddress, PropertySplitCity
From PortfolioProject.dbo.NashvilleHousing 



------------ Now Looking at the Owner Address


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing 



SELECT 
     REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 1)) AS [Street]
   , REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 2)) AS [City]
   , REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 3)) AS [State]
From PortfolioProject.dbo.NashvilleHousing 


--Adding these to the table

ALTER TABLE NashvilleHousing
ADD OwnerSplitStreet varchar(255);

Update NashvilleHousing
SET OwnerSplitStreet = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 1))


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity varchar(255);

Update NashvilleHousing
SET OwnerSplitCity = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 2))




ALTER TABLE NashvilleHousing
ADD OwnerSplitState varchar(255);

Update NashvilleHousing
SET OwnerSplitState = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 3))


Select *
From PortfolioProject.dbo.NashvilleHousing 



--------------------------------------------------------------------------

--Change 'Y' and 'N' to 'Yes' and 'No' in the SoldAsVacant field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing 
Group by SoldAsVacant
Order by 2


UPDATE NashvilleHousing
SET SoldAsVacant='Yes'
WHERE SoldAsVacant='Y';


UPDATE NashvilleHousing
SET SoldAsVacant='No'
WHERE SoldAsVacant='N';



-----------------------------------------------------------------------------------------------------------------------

-- Deleting Duplicates 

WITH RowNumcte AS (
	SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
		ORDER BY 
					 UniqueID
					 ) row_num

		 FROM PortfolioProject.dbo.NashvilleHousing )



	DELETE FROM RowNumcte
	WHERE row_num > 1


----------------------------------------------------------------------------------------------------------------------------------

--Deleting Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select * 
From PortfolioProject.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------

--Data Exploration

-- Looking at the average Value of houses by year

Select Distinct(YearBuilt), AVG(TotalValue) AS AverageValueByYear
From PortfolioProject.dbo.NashvilleHousing
Group By YearBuilt
Order By YearBuilt Desc


-- Looking at the Average Value of Houses based on the Number of bedrooms and bathrroms

Select Bedrooms, FullBath, HalfBath, AVG(TotalValue) As AverageValue
From PortfolioProject.dbo.NashvilleHousing
Group By Bedrooms, FullBath, HalfBath
Order By AverageValue Desc



-----------------------------------------------------------------------------------------------------------

--Looking at the effect of Acreage on The house Total Value

Select Acreage, AVG(TotalValue) as AvgValue
From PortfolioProject..NashvilleHousing
GROUP BY Acreage
Order by Acreage Desc


-------------------------------------------------------------------------------------------------------------

--Does the city where a house is located have an effect on the Value of a house

SELECT PropertySplitCity, AVG(TotalValue) as AvgValue
FROM PortfolioProject..NashvilleHousing
GROUP BY PropertySplitCity
ORDER BY AvgValue DESC


--------------------------------------------------------------------------------------------------------

-- Looking at the month that has the highest value of houses sold

--We need to explore the SaleDateConverted field and extract the month only
--Creating a new column for the month

ALTER TABLE NashvilleHousing
ADD MonthSold varchar (255)

UPDATE PortfolioProject..NashvilleHousing
SET MonthSold = MONTH(SaleDateConverted)

Select MonthSold, COUNT(MonthSold) AS NumberOfHousesSold
FROM PortfolioProject..NashvilleHousing
Group By MonthSold
Order By NumberOfHousesSold Desc



---------------------------------------------------------------------------------------------------------------------

--Exploring the effect of the Land Type on the Total Value of houses

SELECT LandUse, AVG(TotalValue) as AveragValue
FROM PortfolioProject..NashvilleHousing
GROUP BY LandUse
ORDER BY AveragValue DESC