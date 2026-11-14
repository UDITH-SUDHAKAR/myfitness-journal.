// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetFoodCollection on Isar {
  IsarCollection<Food> get foods => this.collection();
}

const FoodSchema = CollectionSchema(
  name: r'Food',
  id: -1224223000086120450,
  properties: {
    r'caloriesPerServing': PropertySchema(
      id: 0,
      name: r'caloriesPerServing',
      type: IsarType.double,
    ),
    r'carbsGramsPerServing': PropertySchema(
      id: 1,
      name: r'carbsGramsPerServing',
      type: IsarType.double,
    ),
    r'fatGramsPerServing': PropertySchema(
      id: 2,
      name: r'fatGramsPerServing',
      type: IsarType.double,
    ),
    r'name': PropertySchema(id: 3, name: r'name', type: IsarType.string),
    r'proteinGramsPerServing': PropertySchema(
      id: 4,
      name: r'proteinGramsPerServing',
      type: IsarType.double,
    ),
    r'servingSize': PropertySchema(
      id: 5,
      name: r'servingSize',
      type: IsarType.double,
    ),
    r'servingUnit': PropertySchema(
      id: 6,
      name: r'servingUnit',
      type: IsarType.string,
    ),
  },

  estimateSize: _foodEstimateSize,
  serialize: _foodSerialize,
  deserialize: _foodDeserialize,
  deserializeProp: _foodDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _foodGetId,
  getLinks: _foodGetLinks,
  attach: _foodAttach,
  version: '3.4.1',
);

int _foodEstimateSize(
  Food object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.servingUnit.length * 3;
  return bytesCount;
}

void _foodSerialize(
  Food object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.caloriesPerServing);
  writer.writeDouble(offsets[1], object.carbsGramsPerServing);
  writer.writeDouble(offsets[2], object.fatGramsPerServing);
  writer.writeString(offsets[3], object.name);
  writer.writeDouble(offsets[4], object.proteinGramsPerServing);
  writer.writeDouble(offsets[5], object.servingSize);
  writer.writeString(offsets[6], object.servingUnit);
}

Food _foodDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Food(
    caloriesPerServing: reader.readDouble(offsets[0]),
    carbsGramsPerServing: reader.readDouble(offsets[1]),
    fatGramsPerServing: reader.readDouble(offsets[2]),
    id: id,
    name: reader.readString(offsets[3]),
    proteinGramsPerServing: reader.readDouble(offsets[4]),
    servingSize: reader.readDouble(offsets[5]),
    servingUnit: reader.readString(offsets[6]),
  );
  return object;
}

P _foodDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _foodGetId(Food object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _foodGetLinks(Food object) {
  return [];
}

void _foodAttach(IsarCollection<dynamic> col, Id id, Food object) {
  object.id = id;
}

extension FoodQueryWhereSort on QueryBuilder<Food, Food, QWhere> {
  QueryBuilder<Food, Food, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FoodQueryWhere on QueryBuilder<Food, Food, QWhereClause> {
  QueryBuilder<Food, Food, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Food, Food, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Food, Food, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterWhereClause> idBetween(
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

extension FoodQueryFilter on QueryBuilder<Food, Food, QFilterCondition> {
  QueryBuilder<Food, Food, QAfterFilterCondition> caloriesPerServingEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'caloriesPerServing',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> caloriesPerServingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caloriesPerServing',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> caloriesPerServingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caloriesPerServing',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> caloriesPerServingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caloriesPerServing',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> carbsGramsPerServingEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'carbsGramsPerServing',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition>
  carbsGramsPerServingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'carbsGramsPerServing',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> carbsGramsPerServingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'carbsGramsPerServing',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> carbsGramsPerServingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'carbsGramsPerServing',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> fatGramsPerServingEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fatGramsPerServing',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> fatGramsPerServingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fatGramsPerServing',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> fatGramsPerServingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fatGramsPerServing',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> fatGramsPerServingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fatGramsPerServing',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<Food, Food, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<Food, Food, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Food, Food, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Food, Food, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<Food, Food, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<Food, Food, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<Food, Food, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Food, Food, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Food, Food, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Food, Food, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Food, Food, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> proteinGramsPerServingEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'proteinGramsPerServing',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition>
  proteinGramsPerServingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'proteinGramsPerServing',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition>
  proteinGramsPerServingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'proteinGramsPerServing',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> proteinGramsPerServingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'proteinGramsPerServing',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingSizeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'servingSize',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingSizeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'servingSize',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingSizeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'servingSize',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingSizeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'servingSize',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingUnitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'servingUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingUnitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'servingUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingUnitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'servingUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingUnitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'servingUnit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingUnitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'servingUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingUnitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'servingUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingUnitContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'servingUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingUnitMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'servingUnit',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingUnitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'servingUnit', value: ''),
      );
    });
  }

  QueryBuilder<Food, Food, QAfterFilterCondition> servingUnitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'servingUnit', value: ''),
      );
    });
  }
}

extension FoodQueryObject on QueryBuilder<Food, Food, QFilterCondition> {}

extension FoodQueryLinks on QueryBuilder<Food, Food, QFilterCondition> {}

extension FoodQuerySortBy on QueryBuilder<Food, Food, QSortBy> {
  QueryBuilder<Food, Food, QAfterSortBy> sortByCaloriesPerServing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesPerServing', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByCaloriesPerServingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesPerServing', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByCarbsGramsPerServing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGramsPerServing', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByCarbsGramsPerServingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGramsPerServing', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByFatGramsPerServing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGramsPerServing', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByFatGramsPerServingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGramsPerServing', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByProteinGramsPerServing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGramsPerServing', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByProteinGramsPerServingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGramsPerServing', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByServingSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingSize', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByServingSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingSize', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByServingUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingUnit', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> sortByServingUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingUnit', Sort.desc);
    });
  }
}

extension FoodQuerySortThenBy on QueryBuilder<Food, Food, QSortThenBy> {
  QueryBuilder<Food, Food, QAfterSortBy> thenByCaloriesPerServing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesPerServing', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByCaloriesPerServingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesPerServing', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByCarbsGramsPerServing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGramsPerServing', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByCarbsGramsPerServingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGramsPerServing', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByFatGramsPerServing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGramsPerServing', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByFatGramsPerServingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGramsPerServing', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByProteinGramsPerServing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGramsPerServing', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByProteinGramsPerServingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGramsPerServing', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByServingSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingSize', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByServingSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingSize', Sort.desc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByServingUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingUnit', Sort.asc);
    });
  }

  QueryBuilder<Food, Food, QAfterSortBy> thenByServingUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servingUnit', Sort.desc);
    });
  }
}

extension FoodQueryWhereDistinct on QueryBuilder<Food, Food, QDistinct> {
  QueryBuilder<Food, Food, QDistinct> distinctByCaloriesPerServing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caloriesPerServing');
    });
  }

  QueryBuilder<Food, Food, QDistinct> distinctByCarbsGramsPerServing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbsGramsPerServing');
    });
  }

  QueryBuilder<Food, Food, QDistinct> distinctByFatGramsPerServing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatGramsPerServing');
    });
  }

  QueryBuilder<Food, Food, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Food, Food, QDistinct> distinctByProteinGramsPerServing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinGramsPerServing');
    });
  }

  QueryBuilder<Food, Food, QDistinct> distinctByServingSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'servingSize');
    });
  }

  QueryBuilder<Food, Food, QDistinct> distinctByServingUnit({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'servingUnit', caseSensitive: caseSensitive);
    });
  }
}

extension FoodQueryProperty on QueryBuilder<Food, Food, QQueryProperty> {
  QueryBuilder<Food, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Food, double, QQueryOperations> caloriesPerServingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caloriesPerServing');
    });
  }

  QueryBuilder<Food, double, QQueryOperations> carbsGramsPerServingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbsGramsPerServing');
    });
  }

  QueryBuilder<Food, double, QQueryOperations> fatGramsPerServingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatGramsPerServing');
    });
  }

  QueryBuilder<Food, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Food, double, QQueryOperations>
  proteinGramsPerServingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinGramsPerServing');
    });
  }

  QueryBuilder<Food, double, QQueryOperations> servingSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'servingSize');
    });
  }

  QueryBuilder<Food, String, QQueryOperations> servingUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'servingUnit');
    });
  }
}
