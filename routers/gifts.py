import asyncio
from fastapi import APIRouter, HTTPException, Depends, status, UploadFile, File
from pydantic import BaseModel, Field
from typing import List, Dict, Optional

from routers.auth import get_current_user, UserProfile

router = APIRouter(prefix="/gifts", tags=["Gift & Interactive System"])

# Lock to ensure atomic coin/diamond transactions and prevent double spending
gift_transaction_lock = asyncio.Lock()

# Standard user coin balances
USER_BALANCES: Dict[str, int] = {}

# Active room gift events feed
ROOM_GIFT_EVENTS: Dict[str, List[dict]] = {}

# Active physical dining/consumption state trackers (30-second live physics loop)
ACTIVE_CONSUMPTION_STATES: Dict[str, dict] = {}


# --- Comprehensive Landmark, Kitchen, and Coin Gift Models ---
class GiftItem(BaseModel):
    id: str
    name: str
    category: str  # Landmarks, Cuisine, Beverages, GoldCoins, SilverCoins, Noble, Custom
    price: int
    emoji_icon: str
    description: str
    culture_origin: Optional[str] = "Pan-Arab"
    physics_effects: List[str] = []  # Steam, Bubbling, Sizzle, 3DParticle, LiquidPhysics


# --- Pluggable Global Catalog of Arab Cultural Landmarks & Cuisine ---
GIFT_MARKETPLACE_CATALOG: Dict[str, GiftItem] = {
    # 1. Egypt Landmarks (10 items)
    "egypt_pyramids": GiftItem(
        id="egypt_pyramids", name="أهرامات الجيزة العظيمة (Giza Pyramids)",
        category="Landmarks", price=5000, emoji_icon="🔺", culture_origin="Egypt",
        description="صرح أثري خالد يعبر عن شموخ الفراعنة وعظمة التاريخ القديم.",
        physics_effects=["3DParticle", "CinematicLighting", "PharaohGoldenDust"]
    ),
    "egypt_sphinx": GiftItem(id="egypt_sphinx", name="أبو الهول (The Sphinx)", category="Landmarks", price=4500, emoji_icon="🦁", culture_origin="Egypt", description="تمثال الأسد بوجة ملك يمثل الحكمة والقوة الكامنة."),
    "egypt_karnak": GiftItem(id="egypt_karnak", name="معبد الكرنك (Karnak Temple)", category="Landmarks", price=4000, emoji_icon="🏛️", culture_origin="Egypt", description="أكبر معبد ديني قديم يخلد طقوس الملوك والآلهة."),
    "egypt_citadel": GiftItem(id="egypt_citadel", name="قلعة صلاح الدين (Cairo Citadel)", category="Landmarks", price=3500, emoji_icon="🏰", culture_origin="Egypt", description="حصن إسلامي حصين يحرس القاهرة بنقوشه الحربية وتاريخه العريق."),
    "egypt_philae": GiftItem(id="egypt_philae", name="معبد فيلة النوبي (Philae Temple)", category="Landmarks", price=3200, emoji_icon="🏺", culture_origin="Egypt", description="جزيرة الحب والجمال الفرعوني الممتزج بالطبيعة النوبية."),
    "egypt_abusimbel": GiftItem(id="egypt_abusimbel", name="معبد أبو سمبل (Abu Simbel)", category="Landmarks", price=4800, emoji_icon="🌅", culture_origin="Egypt", description="معجز التعامد الشمسي السنوي لفرعون مصر العظيم رمسيس."),
    "egypt_alazhar": GiftItem(id="egypt_alazhar", name="الجامع الأزهر الشريف (Al-Azhar)", category="Landmarks", price=3900, emoji_icon="🕌", culture_origin="Egypt", description="منارة العلم ومركز الإشعاع الحضاري الإسلامي والعربي."),
    "egypt_khan_khalili": GiftItem(id="egypt_khan_khalili", name="خان الخليلي الأثري (Khan el-Khalili)", category="Landmarks", price=2500, emoji_icon="🏪", culture_origin="Egypt", description="أسواق أثرية فواحة بالبخور والمشغولات النحاسية النادرة."),
    "egypt_dahshur": GiftItem(id="egypt_dahshur", name="هرم دهشور المنحني (Dahshur)", category="Landmarks", price=3000, emoji_icon="📐", culture_origin="Egypt", description="هرم سنفرو المنحني الممهد لهندسة الأهرامات الكاملة."),
    "egypt_alex_library": GiftItem(id="egypt_alex_library", name="مكتبة الإسكندرية (Alexandria Library)", category="Landmarks", price=3300, emoji_icon="📚", culture_origin="Egypt", description="مكتبة فكرية عالمية ممتزجة بأمواج البحر الأبيض المتوسط."),

    # 2. Morocco Landmarks (10 items)
    "morocco_hassan_tower": GiftItem(
        id="morocco_hassan_tower", name="صومعة حسان بالرباط (Hassan Tower)",
        category="Landmarks", price=4200, emoji_icon="🗼", culture_origin="Morocco",
        description="مئذنة تاريخية غير مكتملة تجسد أوج الفن المعماري الموحدي بالمغرب.",
        physics_effects=["3DParticle", "AndalucianGlow"]
    ),
    "morocco_koutoubia": GiftItem(id="morocco_koutoubia", name="جامع الكتبية بمراكش (Koutoubia)", category="Landmarks", price=4100, emoji_icon="🕌", culture_origin="Morocco", description="منارة الأندلس الروحية وحارسة ساحة جامع الفناء الشهيرة."),
    "morocco_bahia_palace": GiftItem(id="morocco_bahia_palace", name="قصر البهية الفاخر (Bahia Palace)", category="Landmarks", price=3600, emoji_icon="🏛️", culture_origin="Morocco", description="تحفة من الزليج المغربي والحدائق الأندلسية العطرة."),
    "morocco_volubilis": GiftItem(id="morocco_volubilis", name="وليلي الأثرية (Volubilis)", category="Landmarks", price=2800, emoji_icon="🧱", culture_origin="Morocco", description="أطلال رومانية عريقة وسط جبال الأطلس المغربي الخصبة."),
    "morocco_chellah": GiftItem(id="morocco_chellah", name="شالة المرينية الأثرية (Chellah)", category="Landmarks", price=2900, emoji_icon="🏵️", culture_origin="Morocco", description="موقع أثري ساحر يمتزج فيه عبق الرومان وحضارات الإسلام المتلاحقة."),
    "morocco_ait_benhaddou": GiftItem(id="morocco_ait_benhaddou", name="قصبة آيت بن حدو (Ait Benhaddou)", category="Landmarks", price=4400, emoji_icon="🛖", culture_origin="Morocco", description="قرية طينية حمراء ساحرة أدرجت كإرث عالمي ملهم للسينما."),
    "morocco_oudayas": GiftItem(id="morocco_oudayas", name="قصبة الأوداية (Oudayas Kasbah)", category="Landmarks", price=3200, emoji_icon="🌊", culture_origin="Morocco", description="أسوار أندلسية زرقاء تطل على مصب نهر أبي رقراق والمحيط."),
    "morocco_marrakesh_medina": GiftItem(id="morocco_marrakesh_medina", name="المدينة العتيقة لمراكش (Marrakesh Medina)", category="Landmarks", price=3700, emoji_icon="🛍️", culture_origin="Morocco", description="أزقة حمراء ضيقة وصناعات يدوية تقليدية تشع بالحيوية والدفء."),
    "morocco_tinmal": GiftItem(id="morocco_tinmal", name="مسجد تينمل التاريخي (Tin Mal)", category="Landmarks", price=3100, emoji_icon="🏛️", culture_origin="Morocco", description="مهد الدولة الموحدية التاريخي بين قمم جبال الأطلس الكبير."),
    "morocco_saadian_tombs": GiftItem(id="morocco_saadian_tombs", name="الأضرحة السعدية (Saadian Tombs)", category="Landmarks", price=3400, emoji_icon="🏺", culture_origin="Morocco", description="مدافن ملكية بنقوش رخامية وجبسية دقيقة تبهر الناظرين."),

    # 3. Iraq Landmarks (10 items)
    "iraq_babylon": GiftItem(
        id="iraq_babylon", name="بابل الأثرية والأسوار (Ancient Babylon)",
        category="Landmarks", price=4900, emoji_icon="🦁", culture_origin="Iraq",
        description="مهد القوانين والحدائق المعلقة وصاحبة أسد بابل الشهير.",
        physics_effects=["3DParticle", "MesopotamianMist"]
    ),
    "iraq_ishtar_gate": GiftItem(id="iraq_ishtar_gate", name="بوابة عشتار البابلية (Ishtar Gate)", category="Landmarks", price=4600, emoji_icon="🚪", culture_origin="Iraq", description="بوابة بابل الزرقاء المزينة بنقوش التنانين والثيران الأسطورية."),
    "iraq_ur_ziggurat": GiftItem(id="iraq_ur_ziggurat", name="زقورة أور السومرية (Ziggurat of Ur)", category="Landmarks", price=4500, emoji_icon="🪜", culture_origin="Iraq", description="بناء هرمي سومري شامخ يربط الأرض بالسماء السومرية العظيمة."),
    "iraq_mutanabbi": GiftItem(id="iraq_mutanabbi", name="شارع المتنبي الثقافي (Al-Mutanabbi Street)", category="Landmarks", price=3000, emoji_icon="📜", culture_origin="Iraq", description="شريان الثقافة والأدب العراقي البغدادي على ضفاف دجلة."),
    "iraq_ctesiphon": GiftItem(id="iraq_ctesiphon", name="طاق كسرى التاريخي (Ctesiphon Arch)", category="Landmarks", price=3800, emoji_icon="🏹", culture_origin="Iraq", description="أضخم طاق مشيد من الآجر واللبن دون أعمدة في العالم القديم."),
    "iraq_erbil_citadel": GiftItem(id="iraq_erbil_citadel", name="قلعة أربيل الأثرية (Erbil Citadel)", category="Landmarks", price=4200, emoji_icon="🏰", culture_origin="Iraq", description="أقدم قلعة مأهولة بالسكان عبر التاريخ تتوسط مدينة أربيل."),
    "iraq_samarra_minaret": GiftItem(id="iraq_samarra_minaret", name="ملوية سامراء الملتوية (Samarra Minaret)", category="Landmarks", price=4700, emoji_icon="🌪️", culture_origin="Iraq", description="مأذنة مسجد سامراء ملوية الشكل الفريد تلهم عشاق الفلك والجمال."),
    "iraq_hatra": GiftItem(id="iraq_hatra", name="مملكة الحضر العريقة (Ancient Hatra)", category="Landmarks", price=3500, emoji_icon="🏺", culture_origin="Iraq", description="مدينة الشمس الحضرية ومعابدها الضخمة الصامدة في البادية."),
    "iraq_dur_sharrukin": GiftItem(id="iraq_dur_sharrukin", name="خورساباد الآشورية (Dur-Sharrukin)", category="Landmarks", price=3400, emoji_icon="🏹", culture_origin="Iraq", description="عاصمة الآشوريين الشامخة المنقوشة بثيران مجنحة مذهلة."),
    "iraq_baghdad_round": GiftItem(id="iraq_baghdad_round", name="مدينة بغداد المدورة (Round City)", category="Landmarks", price=4300, emoji_icon="🟢", culture_origin="Iraq", description="تخطيط بغداد العباسي الدائري الفريد الذي حير المهندسين في التناظر والجمال."),

    # 4. Saudi Arabia Landmarks (10 items)
    "saudi_alula": GiftItem(
        id="saudi_alula", name="مدائن صالح والأنباط (Mada'in Salih / AlUla)",
        category="Landmarks", price=5000, emoji_icon="🏜️", culture_origin="Saudi Arabia",
        description="مقابر صخرية مهيبة منحوتة في جبال العلا الساحرة تروي قصة حضارات الأنباط العريقة.",
        physics_effects=["3DParticle", "DesertSandstormGlow"]
    ),
    "saudi_diriyah": GiftItem(id="saudi_diriyah", name="الدرعية التاريخية وحي الطريف (Diriyah)", category="Landmarks", price=4800, emoji_icon="🛖", culture_origin="Saudi Arabia", description="مهد الدولة السعودية ودرة العمارة النجدية الطينية الخالدة."),
    "saudi_albalad": GiftItem(id="saudi_albalad", name="البلد وجدة التاريخية (Al-Balad Jeddah)", category="Landmarks", price=3800, emoji_icon="🏢", culture_origin="Saudi Arabia", description="رواشين خشبية وبناء حجري تقليدي يمتزج بنسمات البحر الأحمر."),
    "saudi_masmak": GiftItem(id="saudi_masmak", name="قصر المصمك التاريخي (Masmak Fortress)", category="Landmarks", price=3600, emoji_icon="🏰", culture_origin="Saudi Arabia", description="حصن طيني سميك يتوسط الرياض يروي قصة التأسيس الشامخة."),
    "saudi_elephant_rock": GiftItem(id="saudi_elephant_rock", name="جبل الفيل بالصحراء (Elephant Rock)", category="Landmarks", price=3400, emoji_icon="🐘", culture_origin="Saudi Arabia", description="أعجوبة جيولوجية طبيعية تشبه الفيل الرابض في قلب رمال العلا."),
    "saudi_tabuk_castle": GiftItem(id="saudi_tabuk_castle", name="قلعة تبوك الأثرية (Tabuk Castle)", category="Landmarks", price=3100, emoji_icon="🏰", culture_origin="Saudi Arabia", description="حصن عثماني عريق يحمي قوافل الحجاج القادمة من بلاد الشام."),
    "saudi_dhee_ayn": GiftItem(id="saudi_dhee_ayn", name="قرية ذي عين الأثرية (Dhee Ayn)", category="Landmarks", price=4200, emoji_icon="🏘️", culture_origin="Saudi Arabia", description="قرية حجرية مبنية على جبل من المرمر الأبيض تحيط بها مزارع الموز والريحان الجبلية."),
    "saudi_khaybar": GiftItem(id="saudi_khaybar", name="حصون خيبر الصخرية (Khaybar Fort)", category="Landmarks", price=3900, emoji_icon="⚔️", culture_origin="Saudi Arabia", description="واحة خضراء بين حرات الحمم البركانية السوداء الشامخة."),
    "saudi_qasr_farid": GiftItem(id="saudi_qasr_farid", name="قصر الفريد بالعلا (Qasr Al-Farid)", category="Landmarks", price=4300, emoji_icon="🏛️", culture_origin="Saudi Arabia", description="مقبرة نبطية وحيدة منحوتة في صخرة واحدة مستقلة ومبهرة."),
    "saudi_jubbah": GiftItem(id="saudi_jubbah", name="نقوش جبة الصخرية (Jubbah Rock Art)", category="Landmarks", price=3000, emoji_icon="🪨", culture_origin="Saudi Arabia", description="رسوم ونقوش صخرية ثمودية تعود لآلاف السنين قبل الميلاد في حائل."),

    # 5. Yemen Landmarks (10 items)
    "yemen_sana_old": GiftItem(
        id="yemen_sana_old", name="صنعاء القديمة الساحرة (Sana'a Old City)",
        category="Landmarks", price=4800, emoji_icon="🏢", culture_origin="Yemen",
        description="مبانٍ طينية شاهقة مزينة بنقوش الجبس الأبيض الفريدة ومحاطة بالجبال الشامخة.",
        physics_effects=["3DParticle", "YemenMountainMist"]
    ),
    "yemen_shibam": GiftItem(id="yemen_shibam", name="شبام حضرموت ناطحات الطين (Shibam)", category="Landmarks", price=4700, emoji_icon="🧱", culture_origin="Yemen", description="مانهاتن الصحراء الطينية الشاهقة الشاهدة على عبقرية المعماري اليمني."),
    "yemen_al_saleh": GiftItem(id="yemen_al_saleh", name="جامع الصالح بصنعاء (Al-Saleh Mosque)", category="Landmarks", price=4100, emoji_icon="🕌", culture_origin="Yemen", description="جامع برونزي وحجري يتألق بالمنارات المهيبة والنقوش البديعة."),
    "yemen_dar_hajar": GiftItem(id="yemen_dar_hajar", name="دار الحجر وقصر الصخرة (Dar al-Hajar)", category="Landmarks", price=4400, emoji_icon="🏢", culture_origin="Yemen", description="قصر يمني مهيب مشيد على قمة صخرة شاهقة في وادي ظهر."),
    "yemen_socotra": GiftItem(id="yemen_socotra", name="شجرة دم الأخوين بسقطرى (Socotra)", category="Landmarks", price=5000, emoji_icon="🌲", culture_origin="Yemen", description="شجرة أسطورية ونباتات فريدة في جزيرة سقطرى النادرة الساحرة."),
    "yemen_zabid": GiftItem(id="yemen_zabid", name="مدينة زبيد العلمية (Ancient Zabid)", category="Landmarks", price=3200, emoji_icon="🕌", culture_origin="Yemen", description="مدينة تراثية منارة للفقه والعلوم وموطن ابتكار علم الجبر الساحر."),
    "yemen_qishn": GiftItem(id="yemen_qishn", name="قصر السلطان في قشن (Qishn Palace)", category="Landmarks", price=3500, emoji_icon="🏰", culture_origin="Yemen", description="قصر تراثي يروي تاريخ السلطنة المهرية في جنوب شبه الجزيرة."),
    "yemen_amran": GiftItem(id="yemen_amran", name="مدينة عمران الطينية (Amran)", category="Landmarks", price=3100, emoji_icon="🏘️", culture_origin="Yemen", description="أسوار ومبانٍ طينية تقليدية قديمة تحتضن تاريخ الهمدانيين والسبئيين."),
    "yemen_qahira": GiftItem(id="yemen_qahira", name="قلعة القاهرة بتعز (Al-Qahira Castle)", category="Landmarks", price=4300, emoji_icon="🏰", culture_origin="Yemen", description="قلعة صخرية مهيبة تعتلي جبل صبر وتحرس تعز الأبية بنقوشها الدفاعية."),
    "yemen_taiz_mosque": GiftItem(id="yemen_taiz_mosque", name="مسجد الأشرفية بتعز (Ashrafiya Mosque)", category="Landmarks", price=3400, emoji_icon="🕌", culture_origin="Yemen", description="مسجد أثري يتألق بالقباب البيضاء والنقوش الملونة من عصر بني رسول."),

    # 6. Alf-Leila Kitchen - Pan-Arab Cuisine
    "dish_koshary": GiftItem(
        id="dish_koshary", name="الكشري المصري (Egyptian Koshary)",
        category="Cuisine", price=120, emoji_icon="🍜", culture_origin="Egypt",
        description="طبق شعبي مكون من مكرونة وأرز وعدس وبصل مقرمش ودقة حارة فواحة بالبخار.",
        physics_effects=["Steam", "Sizzle"]
    ),
    "dish_kabsa": GiftItem(
        id="dish_kabsa", name="الكبسة السعودية (Saudi Kabsa)",
        category="Cuisine", price=250, emoji_icon="🍛", culture_origin="Saudi Arabia",
        description="أرز البسمتي بالبهارات النجفية الفاخرة المزين باللحم والمكسرات الساخنة المطهوة بحب.",
        physics_effects=["Steam", "Sizzle"]
    ),
    "dish_couscous": GiftItem(
        id="dish_couscous", name="الكسكس والطاجين المغربي (Moroccan Couscous)",
        category="Cuisine", price=300, emoji_icon="🍲", culture_origin="Morocco",
        description="طاجين طيني مغربي فواح ببخار الخضار واللحم المطهو على نار هادئة.",
        physics_effects=["Steam", "Bubbling"]
    ),
    "dish_mansaf": GiftItem(id="dish_mansaf", name="المنسف الأردني (Levantine Mansaf)", category="Cuisine", price=350, emoji_icon="🍖", culture_origin="Jordan", description="لحم مطهو بالجميد الكركي والأرز والسمن البلدي.", physics_effects=["Steam"]),
    "dish_brik": GiftItem(id="dish_brik", name="البريك التونسي (Tunisian Brik)", category="Cuisine", price=80, emoji_icon="🌮", culture_origin="Tunisia", description="فطيرة مقرمشة محشوة بالبيض والبطاطس والتونة الساخنة والمقرمشة.", physics_effects=["Sizzle"]),

    # 7. Alf-Leila Cafes - Pan-Arab Beverages
    "drink_atay": GiftItem(
        id="drink_atay", name="شاي أتاي المغربي بالنعناع (Moroccan Atay)",
        category="Beverages", price=50, emoji_icon="🍵", culture_origin="Morocco",
        description="شاي أخضر مغربي تقليدي يصب من علو مرتفع بالنعناع الطازج ليعلوه الرغوة الكثيفة.",
        physics_effects=["Steam", "LiquidPhysics"]
    ),
    "drink_coffee": GiftItem(
        id="drink_coffee", name="القهوة السعودية بالهيل (Saudi Coffee)",
        category="Beverages", price=60, emoji_icon="☕", culture_origin="Saudi Arabia",
        description="قهوة شقراء مبهّرة بالهيل والزعفران تصب بمهارة في الدلة والبلبل الفنجان الفاخر.",
        physics_effects=["Steam", "LiquidPhysics"]
    ),
    "drink_tea": GiftItem(
        id="drink_tea", name="كوب شاي كشري بغدادي (Egyptian Koshary Tea)",
        category="Beverages", price=30, emoji_icon="🥛", culture_origin="Egypt",
        description="شاي أسود ثقيل محضر بالنعناع المنعش أو أوراق الريحان على الطريقة المصرية.",
        physics_effects=["Steam", "LiquidPhysics"]
    ),

    # 8. Gold & Silver Coins Tabs (Standard)
    "gift_perfume": GiftItem(id="gift_perfume", name="عطر الياسمين (Classic Perfume)", category="GoldCoins", price=150, emoji_icon="🍾", description="زجاجة عطر ياسمين ناعمة فواحة بالبث والجمال."),
    "gift_key": GiftItem(id="gift_key", name="مفتاح الحظ (Lucky Key)", category="SilverCoins", price=30, emoji_icon="🔑", description="مفتاح حظ كلاسيكي لفتح القلوب والابتسامة."),
    "gift_plane": GiftItem(id="gift_plane", name="طائرة ورقية (Paper Plane)", category="SilverCoins", price=10, emoji_icon="✈️", description="طائرة ورقية تطير برسائلك الجميلة بين كراسي الصوت."),
    "gift_cash_gun": GiftItem(id="gift_cash_gun", name="مسدس النقدية (Cash Gun)", category="GoldCoins", price=500, emoji_icon="🔫", description="مسدس يطلق الأوراق النقدية الذهبية حول المسرح."),
    "gift_musical_box": GiftItem(id="gift_musical_box", name="صندوق الموسيقى (Musical Box)", category="GoldCoins", price=800, emoji_icon="📻", description="صندوق كلاسيكي يعزف ألحاناً شرقية خلابة."),

    # 9. Noble Tab (Luxury)
    "gift_royal_crown": GiftItem(id="gift_royal_crown", name="التاج الملكي المرصع (Royal Crown)", category="Noble", price=15000, emoji_icon="👑", description="تاج ملكي مذهب مرصع بالألماس والياقوت الأحمر النادر."),
    "gift_dragon": GiftItem(id="gift_dragon", name="التنين الأسطوري الطائر (Mythical Dragon)", category="Noble", price=50000, emoji_icon="🐉", description="تنين أسطوري ضخم يحلق فوق الغرفة نافثاً لهيب الألعاب النارية."),
    "gift_luxury_car": GiftItem(id="gift_luxury_car", name="اليخت الفاره لليالي (Luxury Yacht)", category="Noble", price=30000, emoji_icon="🚢", description="يخت فخم يرسو في الغرفة حاملاً طاقة متألقة وهدايا ثمينة."),
}


# --- Schemas ---
class GiftSend(BaseModel):
    gift_id: str
    room_id: str
    receiver_id: str = Field(..., description="The user ID of the recipient on stage/chair")


class GiftSendResponse(BaseModel):
    success: bool
    sender_id: str
    sender_username: str
    receiver_id: str
    gift_id: str
    gift_name: str
    gift_icon: str
    price: int
    new_balance: int
    message: str


class CustomGiftUpload(BaseModel):
    name: str
    price: int
    emoji_icon: str = "🎁"
    description: str


# --- Endpoints ---

@router.get("/catalog", response_model=List[GiftItem])
async def get_gift_catalog():
    """
    Get the complete categorised Gift Marketplace Catalog.
    Includes Arab landmarks, cuisines, beverages, elite noble tab, and standard keys.
    """
    return list(GIFT_MARKETPLACE_CATALOG.values())


@router.post("/send", response_model=GiftSendResponse)
async def send_gift(payload: GiftSend, current_user: UserProfile = Depends(get_current_user)):
    """
    Send a gift to a participant.
    Checks coin balances, performs atomic deduction, and triggers interactive physical dining/broadcast logs.
    """
    gift_id = payload.gift_id
    room_id = payload.room_id
    receiver_id = payload.receiver_id

    async with gift_transaction_lock:
        if gift_id not in GIFT_MARKETPLACE_CATALOG:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Gift item not found in catalog"
            )

        gift = GIFT_MARKETPLACE_CATALOG[gift_id]

        # Initialize sender balance
        if current_user.id not in USER_BALANCES:
            USER_BALANCES[current_user.id] = 10000

        sender_balance = USER_BALANCES[current_user.id]

        if sender_balance < gift.price:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail="عذراً! رصيدك غير كافٍ لإرسال هذه الهدية. يرجى الشحن أولاً."
            )

        # Deduct coins
        USER_BALANCES[current_user.id] = sender_balance - gift.price

        # Credit receiver
        if receiver_id not in USER_BALANCES:
            USER_BALANCES[receiver_id] = 10000
        USER_BALANCES[receiver_id] += gift.price

        # Live Physical Dining/Consumption state triggers (30-second physics loop)
        if gift.category in ["Cuisine", "Beverages"]:
            ACTIVE_CONSUMPTION_STATES[receiver_id] = {
                "gift_id": gift_id,
                "gift_name": gift.name,
                "gift_icon": gift.emoji_icon,
                "scale_level": 1.0, # Starts full mesh size
                "time_remaining_seconds": 30
            }

        # Log event feed
        if room_id not in ROOM_GIFT_EVENTS:
            ROOM_GIFT_EVENTS[room_id] = []

        event = {
            "sender_id": current_user.id,
            "sender_username": current_user.username,
            "receiver_id": receiver_id,
            "gift_id": gift_id,
            "gift_name": gift.name,
            "gift_icon": gift.emoji_icon,
            "category": gift.category,
            "physics_effects": gift.physics_effects,
            "timestamp": float(asyncio.get_event_loop().time())
        }

        ROOM_GIFT_EVENTS[room_id].append(event)
        if len(ROOM_GIFT_EVENTS[room_id]) > 100:
            ROOM_GIFT_EVENTS[room_id].pop(0)

        return GiftSendResponse(
            success=True,
            sender_id=current_user.id,
            sender_username=current_user.username,
            receiver_id=receiver_id,
            gift_id=gift_id,
            gift_name=gift.name,
            gift_icon=gift.emoji_icon,
            price=gift.price,
            new_balance=USER_BALANCES[current_user.id],
            message=f"تم إرسال {gift.name} بنجاح إلى الغرفة!"
        )


@router.post("/custom/upload", response_model=GiftItem)
async def upload_custom_gift(payload: CustomGiftUpload, current_user: UserProfile = Depends(get_current_user)):
    """
    Custom Tab: Allows users to dynamically register/upload custom gifts or custom asset metadata.
    """
    import uuid
    custom_id = f"custom_gift_{uuid.uuid4().hex[:6]}"

    new_gift = GiftItem(
        id=custom_id,
        name=payload.name,
        category="Custom",
        price=payload.price,
        emoji_icon=payload.emoji_icon,
        description=payload.description,
        culture_origin="UserCustom",
        physics_effects=["3DParticle", "CustomGlow"]
    )

    GIFT_MARKETPLACE_CATALOG[custom_id] = new_gift
    return new_gift


@router.get("/consumption/{user_id}")
async def get_dining_consumption_state(user_id: str):
    """
    Retrieve active physical food/beverage dining physics state (mesh scale, steam level, seconds remaining).
    """
    state = ACTIVE_CONSUMPTION_STATES.get(user_id)
    if state:
        # Simulate local decrement check on polling
        import time
        return state
    return {"active": False}
