// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetNutritionEntryCollection on Isar {
  IsarCollection<NutritionEntry> get nutritionEntrys => this.collection();
}

const NutritionEntrySchema = CollectionSchema(
  name: r'NutritionEntry',
  id: 8369953508125321761,
  properties: {
    r'calories': PropertySchema(id: 0, name: r'calories', type: IsarType.long),
    r'date': PropertySchema(id: 1, name: r'date', type: IsarType.dateTime),
    r'name': PropertySchema(id: 2, name: r'name', type: IsarType.string),
    r'proteinGrams': PropertySchema(
      id: 3,
      name: r'proteinGrams',
      type: IsarType.double,
    ),
  },

  estimateSize: _nutritionEntryEstimateSize,
  serialize: _nutritionEntrySerialize,
  deserialize: _nutritionEntryDeserialize,
  deserializeProp: _nutritionEntryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _nutritionEntryGetId,
  getLinks: _nutritionEntryGetLinks,
  attach: _nutritionEntryAttach,
  version: '3.4.1',
);

int _nutritionEntryEstimateSize(
  NutritionEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _nutritionEntrySerialize(
  NutritionEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.calories);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.name);
  writer.writeDouble(offsets[3], object.proteinGrams);
}

NutritionEntry _nutritionEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NutritionEntry(
    calories: reader.readLong(offsets[0]),
    date: reader.readDateTime(offsets[1]),
    id: id,
    name: reader.readString(offsets[2]),
    proteinGrams: reader.readDouble(offsets[3]),
  );
  return object;
}

P _nutritionEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _nutritionEntryGetId(NutritionEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _nutritionEntryGetLinks(NutritionEntry object) {
  return [];
}

void _nutritionEntryAttach(
  IsarCollection<dynamic> col,
  Id id,
  NutritionEntry object,
) {
  object.id = id;
}

extension NutritionEntryQueryWhereSort
    on QueryBuilder<NutritionEntry, NutritionEntry, QWhere> {
  QueryBuilder<NutritionEntry, NutritionEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NutritionEntryQueryWhere
    on QueryBuilder<NutritionEntry, NutritionEntry, QWhereClause> {
  QueryBuilder<NutritionEntry, NutritionEntry, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension NutritionEntryQueryFilter
    on QueryBuilder<NutritionEntry, NutritionEntry, QFilterCondition> {
  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  caloriesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'calories', value: value),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  caloriesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'calories',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  caloriesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'calories',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  caloriesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'calories',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  dateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  dateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  proteinGramsEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'proteinGrams',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  proteinGramsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'proteinGrams',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  proteinGramsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'proteinGrams',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterFilterCondition>
  proteinGramsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'proteinGrams',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension NutritionEntryQueryObject
    on QueryBuilder<NutritionEntry, NutritionEntry, QFilterCondition> {}

extension NutritionEntryQueryLinks
    on QueryBuilder<NutritionEntry, NutritionEntry, QFilterCondition> {}

extension NutritionEntryQuerySortBy
    on QueryBuilder<NutritionEntry, NutritionEntry, QSortBy> {
  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy> sortByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy>
  sortByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy>
  sortByProteinGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGrams', Sort.asc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy>
  sortByProteinGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGrams', Sort.desc);
    });
  }
}

extension NutritionEntryQuerySortThenBy
    on QueryBuilder<NutritionEntry, NutritionEntry, QSortThenBy> {
  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy> thenByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy>
  thenByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy>
  thenByProteinGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGrams', Sort.asc);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QAfterSortBy>
  thenByProteinGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGrams', Sort.desc);
    });
  }
}

extension NutritionEntryQueryWhereDistinct
    on QueryBuilder<NutritionEntry, NutritionEntry, QDistinct> {
  QueryBuilder<NutritionEntry, NutritionEntry, QDistinct> distinctByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calories');
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NutritionEntry, NutritionEntry, QDistinct>
  distinctByProteinGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinGrams');
    });
  }
}

extension NutritionEntryQueryProperty
    on QueryBuilder<NutritionEntry, NutritionEntry, QQueryProperty> {
  QueryBuilder<NutritionEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NutritionEntry, int, QQueryOperations> caloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calories');
    });
  }

  QueryBuilder<NutritionEntry, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<NutritionEntry, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<NutritionEntry, double, QQueryOperations>
  proteinGramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinGrams');
    });
  }
}
