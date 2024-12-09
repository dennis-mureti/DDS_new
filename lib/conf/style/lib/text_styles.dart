import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/conf/style/lib/colors.dart';
import 'package:distributor/conf/style/lib/fonts.dart';
import 'package:flutter/material.dart';

const TextStyle kLabelTextStyle =
    TextStyle(color: kColorLabelColor1, fontSize: kLabelTextSize);

const kAppBarTextStyle = TextStyle(
    fontFamily: kFontThinBody, fontSize: kMediumTextSize, color: Colors.white);

const kTileLeadingLargeTextStyle = TextStyle(
    fontFamily: kFontBoldBody,
    color: kColorDDSColorDark,
    fontSize: kMediumTextSize);

const kTileLeadingTextStyle = TextStyle(
    fontFamily: kFontThinBody,
    color: kColorDDSColorDark,
    fontSize: kBodyTextSize * 1.1);
const kTileLeadingSecondaryTextStyle = TextStyle(
    fontFamily: kFontThinBody,
    color: kColorDDSPrimaryLight,
    fontSize: kBodyTextSize);
const kTileSubtitleTextStyle = TextStyle(
    fontFamily: kFontLightBody,
    color: kColDDSPrimaryLight,
    fontSize: kLabelTextSize);

const TextStyle kTabTextStyleActive =
    TextStyle(fontFamily: kFontBoldBody, fontSize: kLabelTextSize);

const kTitleTextStyle = TextStyle();
const kSubheadingTextStyle1 =
    TextStyle(fontFamily: kFontBoldHeading, fontSize: kMediumTextSize);

const kPopupLabelTextStyle = TextStyle();

const kDrawerTitleTextStyle = TextStyle();

// Forms
const kFormInputTextStyle = TextStyle(
    fontFamily: kFontLightBody,
    color: kColorLabelColor1,
    fontSize: kBodyTextSize);
const kFormHintTextStyle = TextStyle(
    fontFamily: kFontRegularHeading, color: kColorLabelColor1, fontSize: 14);

const kJourneyConsoleJourney = TextStyle(
    fontSize: kBodyTextSize,
    fontFamily: kFontBoldBody,
    color: Color(0xFF560b25));
const kJourneyConsoleRoute =
    TextStyle(fontSize: 12, fontFamily: kFontBoldBody, color: Colors.black54);
const kJourneyConsoleStatus = TextStyle(
    fontSize: kLabelTextSize,
    fontFamily: kFontBoldBody,
    color: Color(0xFF560b25));
const kJourneyConsoleStops =
    TextStyle(fontSize: 12, fontFamily: kFontBoldBody, color: Colors.black54);

// Use for leading text
const kLeadingBodyText = TextStyle(
    fontSize: kBodyTextSize * 1.0,
    fontFamily: kFontThinBody,
    color: kColorDDSColorDark);

const TextStyle kCartQuantity =
    TextStyle(fontSize: kBodyTextSize, fontFamily: kFontLightBody);

const TextStyle kCartSecondaryStyle =
    TextStyle(fontSize: kBodyTextSize, fontFamily: kFontThinBody);

TextStyle kCommentTextStyle = TextStyle(
    fontSize: kBodyTextSize, fontFamily: kFontThinBody, color: Colors.black87);

const TextStyle kCrateReceivedTextStyle =
    TextStyle(color: Colors.lightGreen, fontFamily: kFontThinBody);
const TextStyle kCrateDroppedTextStyle =
    TextStyle(color: Colors.orange, fontFamily: kFontThinBody);
