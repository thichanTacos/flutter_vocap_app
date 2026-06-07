import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vocab_word.dart';

class VocabApiService {
  // Các URL thử theo thứ tự, lấy URL đầu tiên thành công
  static const _cefrUrls = [
    'https://raw.githubusercontent.com/nicholasmargolis/cefr-vocabulary/main/cefr_vocabulary.json',
    'https://raw.githubusercontent.com/nicholasmargolis/cefr-vocabulary/master/cefr_vocabulary.json',
  ];

  // MyMemory API: dịch Anh→Việt, miễn phí, không cần auth, 5000 từ/ngày
  static const _translateUrl = 'https://api.mymemory.translated.net/get';

  // Fetch CEFR word list — thử URL network trước, dùng fallback nếu thất bại
  Future<Map<String, List<String>>> fetchCefrWordList() async {
    for (final url in _cefrUrls) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 12));
        if (response.statusCode == 200) {
          final raw = json.decode(response.body) as Map<String, dynamic>;
          // Validate: phải có ít nhất một key cefr
          if (raw.keys.any((k) => ['a1','a2','b1','b2','c1','c2'].contains(k.toLowerCase()))) {
            return raw.map((key, value) {
              final words = (value as List).cast<String>();
              return MapEntry(key.toLowerCase(), words);
            });
          }
        }
      } catch (_) {
        continue;
      }
    }
    // Dùng danh sách nhúng sẵn nếu tất cả URL đều thất bại
    return _builtinWordList;
  }

  // Dịch từ tiếng Anh sang tiếng Việt qua MyMemory API
  Future<VocabWord?> fetchWordDefinition(String word, String level) async {
    try {
      final uri = Uri.parse(_translateUrl).replace(queryParameters: {
        'q': word,
        'langpair': 'en|vi',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final translated =
          (data['responseData'] as Map<String, dynamic>?)?['translatedText'] as String?;
      if (translated == null || translated.isEmpty) return null;

      return VocabWord(
        term: word,
        definition: translated,
        level: level,
      );
    } catch (_) {
      return null;
    }
  }

  // Danh sách từ nhúng sẵn — dùng khi không có mạng hoặc URL thất bại
  static const _builtinWordList = <String, List<String>>{
    'a1': [
      'able','about','above','across','act','after','again','age','ago','agree',
      'air','all','almost','alone','along','also','always','animal','another','answer',
      'any','area','arm','around','ask','away','back','bad','ball','bank',
      'because','bed','before','begin','behind','below','between','big','book','both',
      'box','boy','bring','brother','buy','call','can','car','carry','cat',
      'change','check','child','city','close','cold','come','computer','country','course',
      'cut','day','different','dog','door','down','dream','drink','drive','eat',
      'end','every','face','fall','family','far','feel','find','food','friend',
      'give','good','great','group','grow','hand','happy','have','help','high',
      'hold','home','house','human','idea','job','keep','know','land','last',
      'learn','left','let','life','light','like','list','live','long','look',
      'love','make','man','many','maybe','mean','money','more','move','much',
      'name','need','never','new','next','now','number','old','open','other',
      'page','part','people','place','plant','play','point','problem','put','question',
      'read','really','right','road','room','run','same','say','school','see',
      'short','show','side','small','some','soon','speak','start','still','stop',
      'study','take','talk','tell','thing','think','time','today','together','top',
      'turn','under','use','very','wait','walk','want','water','way','week',
      'well','white','why','will','woman','word','work','world','year','your',
    ],
    'a2': [
      'accept','achieve','activity','add','advantage','advice','afraid','agent','allow','amount',
      'angry','announce','appear','apply','appreciate','arrive','ask','attack','attend','attitude',
      'available','aware','base','basic','become','behavior','believe','belong','benefit','bill',
      'borrow','break','build','business','careful','cause','centre','certain','character','choose',
      'collect','comfortable','company','compare','complete','condition','connect','consider','contain','continue',
      'control','conversation','correct','cover','create','culture','damage','decide','describe','develop',
      'discover','discuss','distance','divide','doubt','earn','effect','effort','employ','enable',
      'enjoy','enter','environment','equal','escape','event','exactly','example','expect','experience',
      'explain','express','fail','feature','fill','finally','finish','follow','force','form',
      'forward','future','general','government','happen','hard','health','history','hospital','hour',
      'identify','improve','include','increase','independent','individual','inform','inside','interest','introduce',
      'invite','involve','island','issue','journey','kind','language','leader','level','local',
      'manage','meeting','mention','message','method','might','mind','minute','modern','moment',
      'nature','north','notice','offer','order','outside','particular','perform','personal','plan',
      'popular','position','possible','prepare','present','prevent','produce','professional','progress','provide',
      'public','reason','receive','recent','record','reduce','refer','relate','remember','repeat',
      'report','require','research','result','return','review','rise','save','search','seem',
      'send','sense','serious','several','similar','simple','situation','skill','society','solution',
      'south','special','specific','spend','succeed','support','system','therefore','thought','travel',
      'treatment','trust','understand','value','variety','view','visit','voice','waste','weather',
    ],
    'b1': [
      'abandon','absorb','abstract','abundant','academic','access','accommodate','accomplish','accurate','adapt',
      'adequate','adjust','administration','advocate','affect','affirm','allocate','alternative','analyse','anticipate',
      'apparent','approach','appropriate','approve','arbitrary','assess','associate','assume','assure','attempt',
      'authority','avoid','balance','boundary','capacity','challenge','circumstance','claim','classify','coherent',
      'commit','communicate','complex','comprehensive','concentrate','conclude','confuse','consequently','construct','contrast',
      'controversy','cooperate','cope','council','debate','decision','declare','dedicate','define','deliberate',
      'demonstrate','deny','depend','detail','determine','distinguish','distribute','diversity','dominant','dynamic',
      'economy','educate','eliminate','emphasize','enable','encounter','enormous','ensure','estimate','evaluate',
      'evolve','examine','exchange','exclude','expand','extract','factor','fiction','flexibility','focus',
      'formulate','foundation','function','fundamental','generate','global','guideline','highlight','hypothesis','identify',
      'illustrate','implement','imply','indicate','influence','inherit','initiative','integrate','interpret','investigate',
      'justify','knowledge','legislation','maintain','major','mechanism','modify','monitor','motivate','negotiate',
      'network','neutral','obvious','occur','operate','perspective','potential','principle','process','prospect',
      'pursue','recognition','recommend','reinforce','relevant','reluctant','resolve','restrict','retain','reveal',
      'scheme','significant','specific','strategy','structure','substantial','sufficient','summarize','survey','sustainable',
      'technique','theory','transformation','transparent','trend','ultimate','unique','utilize','valid','variable',
    ],
    'b2': [
      'abolish','abstract','accelerate','accessibility','accumulate','acknowledge','acquisition','acute','adjacent','administration',
      'aggregate','alignment','alleviate','ambiguous','amend','analogy','anonymity','anticipate','antiquated','appreciation',
      'arbitrary','articulate','assert','assumption','attribute','augment','authentic','autonomy','benchmark','bias',
      'catastrophic','characterize','chronological','coherent','collaborate','commence','commodity','compensate','complement','compliance',
      'comprehensive','compromise','conceive','concurrent','condense','constitute','constraint','contemplate','contradiction','controversy',
      'conviction','correlate','criteria','cumulative','declaration','deduce','deficiency','depict','depreciate','derive',
      'deteriorate','differentiate','diminish','discrepancy','diversify','elaborate','eliminate','empirical','enhance','entail',
      'equate','ethical','evaluate','evolve','explicit','facilitate','fluctuate','formulate','framework','generate',
      'global','hierarchy','hypothesis','implicit','inadequate','incorporate','infer','infrastructure','inherent','initiate',
      'innovation','integrity','interaction','juxtapose','legitimate','methodology','minimize','moderate','navigate','neutral',
      'objective','phenomenon','predominant','preliminary','prohibit','promote','proportion','qualitative','quantitative','rational',
      'reinforce','relevance','reliable','resilient','restrict','rhetoric','robust','scrutinize','sequence','simulate',
      'sophisticated','specify','stabilize','stimulate','subordinate','supplement','sustainable','synthesize','terminate','transformation',
    ],
    'c1': [
      'abstraction','accountability','accumulation','acknowledgment','acquisition','advocacy','affirmation','ambiguity','ameliorate','analogy',
      'anomaly','apparatus','articulation','assertion','attribution','augmentation','autonomy','bureaucracy','catalyst','chronological',
      'circumvent','cohesion','collaboratively','commodification','conceptualize','consolidation','constituents','correlation','cynicism','decentralize',
      'deliberation','demonstrate','dependency','discourse','disseminate','embody','empiricism','endeavour','epistemology','equilibrium',
      'eradicate','ethical','exemplify','exploitation','fluctuation','formulation','fragmentation','governance','hierarchy','ideology',
      'imperative','implementation','indigenous','inequality','infrastructure','inherently','innovation','integration','intervention','juxtaposition',
      'legitimacy','magnitude','manifestation','marginalization','mechanism','methodology','mitigation','mobilize','modality','narrative',
      'normative','objectivity','optimization','orientation','paradigm','perpetuate','phenomenon','polarization','pragmatic','predominance',
      'presumption','proliferation','propaganda','proportionality','rationalize','reconciliation','redistribution','reinstatement','resilience','rhetoric',
      'scrutiny','socialization','sophistication','speculation','stratification','subordination','sustainability','systematically','theoretical','transformation',
    ],
    'c2': [
      'acrimony','adumbrate','ambivalence','amelioration','anachronism','anthropomorphize','apotheosis','arcane','articulation','assiduous',
      'attenuation','augur','autonomous','bellicose','bifurcation','byzantine','cacophony','circumlocution','cogitation','commensurate',
      'consternation','contumacious','convolution','delineation','denouement','depredation','dialectical','disingenuous','ebullient','effervescent',
      'egregious','elucidation','embellishment','empiricism','encapsulate','enervate','ephemeral','equivocate','esoteric','euphemism',
      'exacerbate','excoriate','exigent','exonerate','expedient','expropriation','extirpate','fallacious','febrile','fecund',
      'garrulous','grandiloquent','hegemony','hyperbole','iconoclast','idiosyncratic','immutable','impecunious','impervious','inchoate',
      'incoherence','incongruity','indefatigable','ingenuous','insidious','intransigent','inveterate','irrevocable','juxtapose','labyrinthine',
      'laconic','loquacious','machiavellian','magnanimous','melancholy','mendacious','meticulous','misanthrope','obsequious','obstreperous',
      'omniscient','ostensible','paradigmatic','paradoxical','paternalism','pedantic','perspicacious','pernicious','pertinacious','prevaricate',
      'propitious','querulous','recalcitrant','repudiation','sanguine','solipsism','sophistry','supercilious','tenacious','vacillate',
    ],
  };
}
