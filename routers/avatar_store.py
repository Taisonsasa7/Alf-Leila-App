import asyncio
from fastapi import APIRouter, HTTPException, Depends, status, UploadFile, File
from pydantic import BaseModel, Field
from typing import List, Dict, Optional

from routers.auth import get_current_user, UserProfile

router = APIRouter(prefix="/avatar-store", tags=["Avatar Marketplace"])

# Lock to ensure atomic coin/diamond transactions and prevent double spending
store_transaction_lock = asyncio.Lock()


# --- Wardrobe Data Models ---
class WardrobeItem(BaseModel):
    id: str
    name: str
    category: str  # Traditional, Modest, Modern, Tech, Smoke, Perfume
    culture_origin: Optional[str] = None  # Saudi, Moroccan, Egyptian, Tunisian, etc.
    price_permanent: int  # Price to unlock permanently
    price_rental_30d: int  # Price for 30 days rental
    emoji_icon: str
    description: str
    color_palette: List[str] = ["#FFFFFF"]


# --- Modular Pluggable Store Catalog ---
WARDROBE_CATALOG: Dict[str, WardrobeItem] = {
    # 1. Traditional Arab Heritage Clothing
    "saudi_thobe": WardrobeItem(
        id="saudi_thobe",
        name="الثوب السعودي الأصيل والشماغ (Saudi Thobe & Shemagh)",
        category="Traditional",
        culture_origin="Saudi Arabia",
        price_permanent=1500,
        price_rental_30d=300,
        emoji_icon="👳",
        description="ثوب أبيض فاخر مع شماغ أحمر بنقوش قشيبية أصيلة يعبر عن هيبة الخليج.",
        color_palette=["#FFFFFF", "#F5F5F5", "#E0E0E0"]
    ),
    "moroccan_caftan": WardrobeItem(
        id="moroccan_caftan",
        name="القفطان المغربي المطرز (Moroccan Caftan)",
        category="Traditional",
        culture_origin="Morocco",
        price_permanent=2000,
        price_rental_30d=400,
        emoji_icon="👘",
        description="قفطان مغربي مطرز بخيوط الصقلي المذهبة والحرير الفاخر.",
        color_palette=["#D4AF37", "#800020", "#008080", "#4B0082"]
    ),
    "egyptian_galabiya": WardrobeItem(
        id="egyptian_galabiya",
        name="الجلابية الصعيدية المصرية (Egyptian Galabiya)",
        category="Traditional",
        culture_origin="Egypt",
        price_permanent=1000,
        price_rental_30d=200,
        emoji_icon="🧥",
        description="جلابية صعيدية مصرية مريحة تعبر عن الأصالة والتراث العريق.",
        color_palette=["#4E3629", "#1C1C1C", "#556B2F"]
    ),
    "tunisian_attire": WardrobeItem(
        id="tunisian_attire",
        name="الجبة التونسية بالحرير (Tunisian Jebba)",
        category="Traditional",
        culture_origin="Tunisia",
        price_permanent=1200,
        price_rental_30d=240,
        emoji_icon="🥋",
        description="جبة تونسية تقليدية منسوجة بالحرير والخمري الفاتح.",
        color_palette=["#E0B0FF", "#FFFFFF", "#F0E68C"]
    ),

    # 2. Islamic & Modest Wear for Women
    "hijab_abaya": WardrobeItem(
        id="hijab_abaya",
        name="العباية والوشاح المطرز (Elegant Abaya & Khimar)",
        category="Modest",
        price_permanent=1800,
        price_rental_30d=350,
        emoji_icon="🧕",
        description="عباية إسلامية سوداء فاخرة مطرزة بالدانتيل مع خمار متناسق.",
        color_palette=["#000000", "#1E1E1E", "#2C3E50"]
    ),
    "niqab_khimar": WardrobeItem(
        id="niqab_khimar",
        name="النقاب الملكي والملحفة (Royal Niqab & Khimar)",
        category="Modest",
        price_permanent=1600,
        price_rental_30d=300,
        emoji_icon="🎭",
        description="نقاب وخمار كامل من قماش الحرير الناعم ومريح للتنفس.",
        color_palette=["#000000", "#2F4F4F", "#3E2723"]
    ),

    # 3. Modern Casual & Formal Wear
    "formal_suit": WardrobeItem(
        id="formal_suit",
        name="البدلة الرسمية الملكية (Premium Formal Suit)",
        category="Modern",
        price_permanent=2200,
        price_rental_30d=450,
        emoji_icon="👔",
        description="بدلة رسمية كلاسيكية فخمة لحضور السهرات والتحديات الكبرى.",
        color_palette=["#0F0F1A", "#1C2833", "#2C3E50"]
    ),

    # 4. Interactive Props & Gadgets
    "prop_headphones": WardrobeItem(
        id="prop_headphones",
        name="سماعات الاستماع الخاص (Interactive Headphones)",
        category="Tech",
        price_permanent=3000,
        price_rental_30d=600,
        emoji_icon="🎧",
        description="سماعات الرأس الذكية. تتيح تفعيل وضع الاستماع للموسيقى الخاصة بشكل مستقل وسري."
    ),
    "prop_shisha": WardrobeItem(
        id="prop_shisha",
        name="الشيشة التفاعلية (Animated Shisha)",
        category="Smoke",
        price_permanent=2500,
        price_rental_30d=500,
        emoji_icon="💨",
        description="شيشة عربية تقليدية مع ميزة إطلاق دخان كثيف وأصوات قرقرة عند التحدث."
    ),
    "prop_perfume": WardrobeItem(
        id="prop_perfume",
        name="عطر ليلة العمر (Interactive Perfume Spray)",
        category="Perfume",
        price_permanent=1200,
        price_rental_30d=240,
        emoji_icon="🍾",
        description="زجاجة عطر فاخرة ترش رذاذاً متألقاً حول الكرسي عند تفعيلها."
    )
}


# --- Schemas ---
class BuyItemRequest(BaseModel):
    item_id: str
    is_permanent: bool = True  # True: Permanent Unlock, False: 30-Day Rental


class DesignOutfitRequest(BaseModel):
    base_color: str
    embroidery_pattern: str  # Arabesque, RoyalGold, Geometric
    text_stitching: Optional[str] = None


class WorkshopStitchResponse(BaseModel):
    success: bool
    outfit_id: str
    animation_sequence: List[str]
    message: str


# --- Endpoints ---

@router.get("/wardrobe", response_model=List[WardrobeItem])
async def get_wardrobe_catalog():
    """
    Get the complete Avatar Wardrobe and items catalog.
    """
    return list(WARDROBE_CATALOG.values())


@router.post("/buy", status_code=status.HTTP_200_OK)
async def purchase_wardrobe_item(
    payload: BuyItemRequest,
    current_user: UserProfile = Depends(get_current_user)
):
    """
    Purchase or rent a wardrobe item using the app's coin/diamond balance.
    Features duration-based diamond rental vs permanent unlock.
    """
    from routers.gifts import USER_BALANCES

    item_id = payload.item_id
    is_perm = payload.is_permanent

    async with store_transaction_lock:
        # Validate item existence
        if item_id not in WARDROBE_CATALOG:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Item not found in catalog"
            )

        item = WARDROBE_CATALOG[item_id]
        price = item.price_permanent if is_perm else item.price_rental_30d

        # Verify user balance
        if current_user.id not in USER_BALANCES:
            USER_BALANCES[current_user.id] = 10000

        balance = USER_BALANCES[current_user.id]

        if balance < price:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail=f"رصيدك غير كافٍ. تحتاج إلى {price} ذهبة لإتمام العملية."
            )

        # Deduct coins
        USER_BALANCES[current_user.id] = balance - price

        # Log rental/unlock status
        term_text = "دائم مدى الحياة" if is_perm else "إيجار لمدة 30 يوماً"

        return {
            "success": True,
            "item_id": item_id,
            "item_name": item.name,
            "price_paid": price,
            "new_balance": USER_BALANCES[current_user.id],
            "unlock_type": "Permanent" if is_perm else "Rental",
            "message": f"تم بنجاح فتح {item.name} ({term_text})!"
        }


@router.post("/tailor/design", response_model=WorkshopStitchResponse)
async def design_custom_outfit(
    payload: DesignOutfitRequest,
    current_user: UserProfile = Depends(get_current_user)
):
    """
    Interactive Tailor & Custom Design Workshop:
    Triggers virtual sewing and embroidery simulation animations, returning custom generated parameters.
    """
    import uuid
    outfit_id = f"custom_outfit_{uuid.uuid4().hex[:6]}"

    # Live tailoring/embroidery animation sequences
    animation_steps = [
        "سحب القماش المختار ومطابقة القياسات...",
        "بدء تشغيل ماكينة الخياطة التفاعلية الفائقة...",
        f"تطبيق نقش التطريز الإسلامي: {payload.embroidery_pattern}...",
        f"حياكة الاسم المخصص على الثوب: {payload.text_stitching or 'ألف ليلة وليلة'}...",
        "كي الكسوة وتطبيق تلميع Shader ثلاثي الأبعاد..."
    ]

    return WorkshopStitchResponse(
        success=True,
        outfit_id=outfit_id,
        animation_sequence=animation_steps,
        message="تمت حياكة وتفصيل كسوتك ثلاثية الأبعاد بنجاح تام!"
    )
