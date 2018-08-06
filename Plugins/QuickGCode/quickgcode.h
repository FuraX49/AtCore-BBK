#ifndef QUICKGCODE_H
#define QUICKGCODE_H

#include <QQuickItem>
#include <QSGGeometryNode>
#include <QFile>
#include <QVector2D>
#include <QVector3D>
#include <QUrl>

typedef struct layer_struct_s
{
    int pos_layer;    /* offset layer in PathBuffer */
    int num_segment;  /* number segment in layer */
} layer_struct;


typedef struct segment_struct_s
{
    float X ;
    float Y;
    bool Ext;
    quint8 Rate;

} segment_struct;




class QuickGCode : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(qint32 layercount READ layercount NOTIFY layercountChanged  FINAL)
    Q_PROPERTY(float nozzlesize READ nozzlesize WRITE setnozzlesize NOTIFY nozzlesizeChanged)
    Q_PROPERTY(QColor pathcolor READ pathcolor WRITE setPathColor NOTIFY pathcolorChanged)
    Q_PROPERTY(QColor extcolor READ extcolor WRITE setExtColor NOTIFY extcolorChanged)
    Q_PROPERTY(int layer READ layer WRITE drawLayer NOTIFY layerChanged)


public:
    QuickGCode(QQuickItem *parent = nullptr);
    ~QuickGCode();
    QSGNode *updatePaintNode(QSGNode *, UpdatePaintNodeData *);
    qint32 layercount() const;
    QUrl source() const;
    void setSource(const QUrl &source);
    float nozzlesize() const;
    QColor pathcolor() const ;
    QColor extcolor() const ;
    int layer() const ;


public Q_SLOTS:
    void parseLayers();
    void drawLayer(const int layer );
    void setnozzlesize(const float &size) ;
    void setPathColor(QColor arg);
    void setExtColor(QColor arg);


signals:
    void layercountChanged(const qint32  &);
    void parseFinish();
    void sourceChanged(const QUrl &);
    void nozzlesizeChanged(const float  &);
    void pathcolorChanged();
    void extcolorChanged();
    void layerChanged();



private:
   // int m_segmentCount;
    QFile m_file;
    QUrl m_filename ;
    QVector<layer_struct_s> m_layerPos;
    QVector<segment_struct_s> m_PathBuffer;
    float m_nozzlesize;
    QColor m_pathcolor;
    QColor m_extcolor;
    int m_layer;
    int m_maxsegments;


};

#endif // QUICKGCODE_H
