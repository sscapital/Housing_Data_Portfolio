--CLEAN DATA


--Explore Dataset 

select * from "Housing_Dataset" limit 50;

--Remove Time description in "SalePrice" Column



ALTER TABLE "Housing_Dataset"
	ALTER COLUMN "SaleDate" TYPE date



----- Split city and address




select "PropertyAddress",
substring("PropertyAddress",0, position(',' in "PropertyAddress")) as address,
substring("PropertyAddress",position(',' in "PropertyAddress")+1) as address2
from "Housing_Dataset";

ALTER TABLE "Housing_Dataset"
	add column "PropertySplitAddress" VARCHAR(255)

ALTER TABLE "Housing_Dataset"
	add column "PropertySplitCity" VARCHAR(255)
	
UPDATE "Housing_Dataset"
	set "PropertySplitAddress" = substring("PropertyAddress",0, position(',' in "PropertyAddress"))
	
UPDATE "Housing_Dataset"
	set "PropertySplitCity" = substring("PropertyAddress",position(',' in "PropertyAddress")+1)




--- Split Owner Address into 3 parts(Address,City,State)




select "OwnerAddress",
split_part("OwnerAddress",',',1),
split_part("OwnerAddress",',',2),
split_part("OwnerAddress",',',3) from "Housing_Dataset"
where "OwnerAddress" is not null;


ALTER TABLE "Housing_Dataset"
	add column "OwnerSplitAddress" VARCHAR(255),
	add column "OwnerSplitCity" VARCHAR(255),
	add column "OwnerSplitState" VARCHAR(255)
	
UPDATE "Housing_Dataset"
	set "OwnerSplitAddress" = split_part("OwnerAddress",',',1),
	"OwnerSplitCity" = split_part("OwnerAddress",',',2),
	"OwnerSplitState" = split_part("OwnerAddress",',',3)




-- Modify "SoldAsVacant" Column




select "SoldAsVacant",count("SoldAsVacant")
from "Housing_Dataset"
group by "SoldAsVacant"
order by 2;

select "SoldAsVacant",
case when "SoldAsVacant" = 'Y' THEN 'Yes'
	when "SoldAsVacant" = 'N' THEN 'No'
	else "SoldAsVacant"
	end
from "Housing_Dataset"

UPDATE "Housing_Dataset"
	set "SoldAsVacant" = (case when "SoldAsVacant" = 'Y' THEN 'Yes'
	when "SoldAsVacant" = 'N' THEN 'No'
	else "SoldAsVacant"
	end)
	




-- Remove Duplicates with CTE




WITH RowNumCTE AS(
	select 
		"ParcelID"
	from (
select "ParcelID", 
	ROW_NUMBER() OVER (
		PARTITION BY "ParcelID", 
					"PropertyAddress",
					"SalePrice",
					"SaleDate",
					"LegalReference"
					ORDER BY 
						"Housing_Dataset"."UniqueID " 
						) row_num
from "Housing_Dataset"
	) s
where row_num > 1
)
DELETE FROM "Housing_Dataset"
--select * from "Housing_Dataset"
WHERE "ParcelID" IN (select * from RowNumCTE)





-- Delete Unused Columns



ALTER TABLE "Housing_Dataset"
DROP COLUMN "OwnerAddress",
DROP COLUMN "TaxDistrict", 
DROP COLUMN "PropertyAddress"




























